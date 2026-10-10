#!/usr/bin/env ruby
# Build-time tool only. No extension is executed by an ordinary spin build.
require "json"
require "open3"
require "tmpdir"
require "shellwords"

module CextRecord
  class Refusal < StandardError; end
  ROOT = File.expand_path("..", __dir__)
  # Only deterministic libc helpers are allowed in this initial subset. In
  # particular getenv/environ, files, clocks, dynamic loading and process APIs
  # cannot be reached even through a local helper in Init.
  LIBC = %w[malloc calloc realloc free memcpy memmove memset memcmp strlen
            strcmp strncmp strcpy strncpy strcat strchr strrchr strstr
            __stack_chk_fail __stack_chk_guard __memcpy_chk __memmove_chk
            __memset_chk __strcpy_chk __strncpy_chk __strcat_chk].freeze
  # Match C tokens after preprocessing, not source-text strings/comments.
  TOKEN = /"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|[A-Za-z_][A-Za-z_0-9]*|(?:0[xX][0-9a-fA-F]+|[0-9]+)[uUlL]*|[^\s]/m
  module_function

  def command(*args)
    out, err, status = Open3.capture3(*args)
    raise Refusal, "#{File.basename(args[0])}: #{err.strip}" unless status.success?
    out
  end

  def c_string(tokens)
    raise Refusal, "rb_intern: method IDs must be literal C strings" unless !tokens.empty? && tokens.all? { |t| t.start_with?('"') }
    value = tokens.map do |t|
      t[1...-1].gsub(/\\(?:[0-7]{1,3}|x[0-9a-fA-F]+|.)/m) do |e|
        case e[1]
        when "0".."7" then e[1..].to_i(8).chr(Encoding::BINARY)
        when "x" then e[2..].to_i(16).chr(Encoding::BINARY)
        when '"', "\\", "?", "'" then e[1]
        when "n" then "\n"
        when "r" then "\r"
        when "t" then "\t"
        else raise Refusal, "rb_intern: unsupported C string escape #{e}"
        end
      end
    end.join
    raise Refusal, "rb_intern: only printable ASCII IDs are supported" unless value.bytes.all? { |b| b >= 32 && b < 127 }
    value
  rescue RangeError
    raise Refusal, "rb_intern: C string escape is out of byte range"
  end

  def source_only(text)
    selected = true
    text.lines.map do |line|
      if line =~ /^#\s+\d+\s+"([^"]+)"(.*)/
        file, flags = $1, $2
        selected = !flags.split.include?("3") && !File.expand_path(file).start_with?(File.join(ROOT, "include") + "/")
        nil
      elsif selected
        line
      end
    end.compact.join
  end

  def arguments(tokens, start)
    args = [[]]; depth = 0; i = start
    while i < tokens.length
      t = tokens[i]
      return [args, i] if t == ")" && depth == 0
      if t == "," && depth == 0
        args << []
      else
        depth += 1 if ["(", "[", "{"].include?(t)
        depth -= 1 if [")", "]", "}"].include?(t)
        args[-1] << t
      end
      i += 1
    end
    raise Refusal, "scanner: unterminated API call"
  end

  def scan(text)
    tokens = source_only(text).scan(TOKEN)
    names = []; arities = []
    tokens.each_with_index do |t, i|
      raise Refusal, "scanner: inline assembly is outside the recorder subset" if %w[asm __asm __asm__].include?(t)
      next unless %w[rb_intern rb_funcall].include?(t)
      raise Refusal, "#{t}: taking an API function address is outside the literal scanner subset" unless tokens[i+1] == "("
      args, = arguments(tokens, i+2)
      if t == "rb_intern"
        raise Refusal, "rb_intern: expected one literal argument" unless args.length == 1
        names << c_string(args[0])
      else
        a = args[2]
        raise Refusal, "rb_funcall: arity must be a nonnegative integer literal" unless a && a.length == 1 && a[0] =~ /\A[0-9]+\z/
        arity = Integer(a[0], 10)
        raise Refusal, "rb_funcall: argument count does not match literal arity" unless args.length == 3 + arity
        arities << arity
      end
    end
    [names.uniq.sort, arities.uniq.sort]
  end

  def write_atomic(path, bytes)
    temp = "#{path}.tmp.#{$$}"
    File.write(temp, bytes)
    File.rename(temp, path)
  ensure
    File.delete(temp) if temp && File.exist?(temp)
  end

  def record(name:, init:, sources:, output:, declarations: nil, object_archive: nil, cflags: [], cc: ENV.fetch("CC", "cc"))
    raise Refusal, "invalid extension name" unless name =~ /\A[A-Za-z_][A-Za-z_0-9]*\z/
    raise Refusal, "invalid Init symbol" unless init =~ /\AInit_[A-Za-z_0-9]+\z/
    raise Refusal, "at least one C source is required" if sources.empty?
    paths = [output, declarations, object_archive].compact.map { |p| File.expand_path(p) }
    raise Refusal, "artifacts need distinct output paths" unless paths.uniq.length == paths.length
    compiler = Shellwords.split(cc)
    raise Refusal, "empty C compiler command" if compiler.empty?
    # Instrumentation/LTO obscure the import check; build the recorder from
    # ordinary objects. User flags cannot replace its header or compiler action.
    raise Refusal, "only -I, -D and -U recorder flags are supported" unless cflags.all? { |f| f =~ /\A-(?:I|D|U).+/ }
    Dir.mktmpdir("spinel-cext-record-") do |dir|
      flags = ["-std=c11", "-O0", "-DSP_CEXT_RECORDER", "-I#{ROOT}/include", *cflags]
      objects = []; names = []; arities = []
      sources.each_with_index do |source, i|
        source = File.expand_path(source)
        raise Refusal, "missing C source #{source}" unless File.file?(source)
        ids, argc = scan(command(*compiler, *flags, "-E", source))
        names.concat(ids); arities.concat(argc)
        obj = File.join(dir, "extension#{i}.o")
        command(*compiler, *flags, "-c", source, "-o", obj)
        objects << obj
      end
      rec = File.join(dir, "recorder.o")
      command(*compiler, *flags, "-I#{ROOT}/tools/cext", "-c", "#{ROOT}/tools/cext/recorder.c", "-o", rec)
      # Cross-TU helpers are definitions of this extension, not imports. Parse
      # nm's portable format on Darwin and GNU binutils, stripping Darwin's
      # single ABI underscore only (not the C identifier's own underscore).
      darwin = RUBY_PLATFORM.include?("darwin")
      defined = []; undefined = []
      [rec, *objects].each do |obj|
        command("nm", "-g", "-P", obj).lines.each do |line|
          sym, type, = line.split
          next unless sym && type
          sym = sym.delete_prefix("_") if darwin
          if type == "U" || type == "w" || type == "v"
            undefined << sym unless obj == rec
          else
            defined << sym
          end
        end
      end
      unknown = undefined.uniq - defined - LIBC
      raise Refusal, "#{unknown.sort.join(', ')}: external API is outside the deterministic recorder subset" unless unknown.empty?
      main = File.join(dir, "main.c")
      File.write(main, "#include \"recorder.h\"\nvoid #{init}(void);\nint main(void) { sp_cext_record_begin(\"#{name}\"); #{init}(); sp_cext_record_finish(); return 0; }\n")
      exe = File.join(dir, "record")
      archive = File.join(dir, "libspinel_cext_rec.a")
      command("ar", "rcs", archive, rec)
      command(*compiler, *flags, "-I#{ROOT}/tools/cext", main, *objects, archive, "-o", exe)
      # A hung Init must not hang the build. Kill the child (capture3's block
      # otherwise waits for it) and keep the previous artifact on failure.
      events = []
      Open3.popen3(exe, pgroup: true) do |stdin, stdout, stderr, wait|
        stdin.close
        out = Thread.new { stdout.read }; err = Thread.new { stderr.read }
        unless wait.join(10)
          Process.kill("KILL", -wait.pid)
          wait.join; out.join; err.join
          raise Refusal, "#{init}: recorder exceeded 10 seconds"
        end
        unless wait.value.success?
          message = err.value.strip
          message = "#{init}: recorder exited with #{wait.value}" if message.empty?
          raise Refusal, message
        end
        events = out.value.lines.map { |line| JSON.parse(line) }
      end
      manifest = {"version" => 1, "extension" => name, "init" => init,
                  "definitions" => events, "literal_ids" => names.uniq.sort,
                  "funcall_arities" => arities.uniq.sort}
      ruby = render(manifest)
      if object_archive
        extension_archive = File.join(dir, "extension.a")
        command("ar", "rcs", extension_archive, *objects)
        write_atomic(object_archive, File.binread(extension_archive))
      end
      write_atomic(declarations, ruby) if declarations
      write_atomic(output, JSON.pretty_generate(manifest) + "\n")
      manifest
    end
  end

  # These internal declarations are artifacts for step 5, not runnable Ruby.
  # String arguments are escaped as Ruby literals; no source text is eval'ed.
  def render(manifest)
    lines = ["# Generated C extension declarations (compiler bridge required).",
             "__cext_extension(#{manifest['extension'].dump}, #{manifest['init'].dump}, 1)"]
    manifest["definitions"].each do |d|
      args = case d["kind"]
             when "class" then [d["path"], d["superclass"]]
             when "module" then [d["path"]]
             when "method" then d.values_at("owner", "name", "scope", "visibility", "arity", "function")
             when "allocator" then d.values_at("owner", "function")
             when "alias" then d.values_at("owner", "name", "original")
             when "attribute" then d.values_at("owner", "name", "read", "write")
             when "include", "extend" then d.values_at("owner", "module")
             when "constant"
               v = d.fetch("value")
               [d["owner"], d["name"], v["type"], v["type"] == "string" ? v["hex"] : v["value"], v["object"], v["frozen"]]
             else raise Refusal, "unknown manifest definition #{d['kind']}"
             end
      literal = args.map { |a| a.is_a?(String) ? a.dump : a.inspect }.join(", ")
      lines << "__cext_#{d['kind']}(#{literal})"
    end
    manifest["literal_ids"].each { |id| lines << "__cext_literal_id(#{id.dump})" }
    manifest["funcall_arities"].each { |arity| lines << "__cext_funcall_arity(#{arity})" }
    lines.join("\n") + "\n"
  end

  def main(args)
    options = {sources: [], cflags: []}
    until args.empty?
      arg = args.shift
      key = {"--name" => :name, "--init" => :init, "--output" => :output, "--cc" => :cc, "--declarations" => :declarations, "--object-archive" => :object_archive, "--cflag" => :cflags}[arg]
      if key
        value = args.shift or raise Refusal, "#{arg} requires a value"
        key == :cflags ? options[key] << value : options[key] = value
      elsif arg.start_with?("-")
        raise Refusal, "unknown option #{arg}"
      else
        options[:sources] << arg
      end
    end
    raise Refusal, "usage: ruby tools/cext-record.rb --name X --init Init_X --output manifest.json [--cflag -Ipath] source.c..." unless [:name, :init, :output].all? { |k| options[k] }
    record(**options)
  rescue Refusal, SystemCallError, JSON::ParserError => e
    warn "spinel cext: #{options[:name]}: #{e.message}"
    2
  else
    0
  end
end
exit CextRecord.main(ARGV) if $PROGRAM_NAME == __FILE__
