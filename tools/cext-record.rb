#!/usr/bin/env ruby
# Build-time tool only. No extension is executed by an ordinary spin build.
require "json"
require "open3"
require "tmpdir"
require "shellwords"

module CextRecord
  class Refusal < StandardError; end
  def self.sdk_root
    program = File.expand_path($PROGRAM_NAME)
    program = File.realpath(program) if File.file?(program)
    dir = File.dirname(program)
    candidates = [dir, File.dirname(dir), File.expand_path("..", __dir__)]
    candidates.each do |candidate|
      return candidate if File.file?(File.join(candidate, "include/ruby.h")) && File.file?(File.join(candidate, "tools/cext/recorder.c"))
    end
    File.expand_path("..", __dir__)
  end
  ROOT = sdk_root
  # Only deterministic libc helpers are allowed in this initial subset. In
  # particular getenv/environ, files, clocks, dynamic loading and process APIs
  # cannot be reached even through a local helper in Init.
  LIBC = %w[malloc calloc realloc free memcpy memmove memset memcmp strlen
            strcmp strncmp strcpy strncpy strcat strchr strrchr strstr
            __stack_chk_fail __stack_chk_guard __memcpy_chk __memmove_chk
            __memset_chk __strcpy_chk __strncpy_chk __strcat_chk].freeze
  OUTLINE_ATOMICS = /\A__aarch64_(?:cas|swp|ld(?:add|clr|eor|set))(?:1|2|4|8|16)_(?:relax|acq|rel|acq_rel|sync)\z/
  # Match C tokens after preprocessing, not source-text strings/comments.
  TOKEN = /"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|[A-Za-z_][A-Za-z_0-9]*|(?:0[xX][0-9a-fA-F]+|[0-9]+)[uUlL]*|[^\s]/m
  module_function

  def command(*args)
    out, err, status = Open3.capture3(*args)
    raise Refusal, "#{File.basename(args[0])}: #{err.strip}" unless status.success?
    out
  end

  def c_string(tokens, api = "rb_intern")
    raise Refusal, "#{api}: method IDs must be literal C strings" unless !tokens.empty? && tokens.all? { |t| t.start_with?('"') }
    value = tokens.map do |t|
      t[1...-1].gsub(/\\(?:[0-7]{1,3}|x[0-9a-fA-F]+|.)/m) do |e|
        case e[1]
        when "0".."7" then e[1..].to_i(8).chr(Encoding::BINARY)
        when "x" then e[2..].to_i(16).chr(Encoding::BINARY)
        when '"', "\\", "?", "'" then e[1]
        when "n" then "\n"
        when "r" then "\r"
        when "t" then "\t"
        else raise Refusal, "#{api}: unsupported C string escape #{e}"
        end
      end
    end.join
    raise Refusal, "#{api}: only printable ASCII IDs are supported" unless value.bytes.all? { |b| (b >= 32 && b < 127) || (api == "rb_eval_string" && [9, 10, 13].include?(b)) }
    value
  rescue RangeError
    raise Refusal, "#{api}: C string escape is out of byte range"
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

  SCANNED = %w[rb_intern rb_intern2 rb_funcall rb_funcallv rb_apply rb_block_call
               rb_iv_get rb_iv_set rb_ivar_get rb_ivar_set rb_ivar_defined rb_const_get rb_const_get_at rb_eval_string].freeze
  # A name without the @ is a hidden ivar (sqlite3's "-instances"): kept where
  # no Ruby code reads it, so it needs no stub.
  HIDDEN_IVAR = /\A-[A-Za-z_][A-Za-z_0-9]*\z/
  DYNAMIC_IDS = %w[rb_to_id rb_check_id rb_sym2id].freeze
  # SYM2ID of a Symbol the program made: a call through that ID is sent as
  # Ruby sends a computed name, over the methods the program defines.
  SYMBOL_IDS = %w[SYM2ID sp_cext_scanned_sym2id].freeze

  def scan(text)
    tokens = source_only(text).scan(TOKEN)
    names = []; arities = []; ivars = []; evals = []; constants = false; computed = false; spread = false
    tokens.each_with_index do |t, i|
      raise Refusal, "scanner: inline assembly is outside the recorder subset" if %w[asm __asm __asm__].include?(t)
      raise Refusal, "#{t}: runtime-computed method IDs are unsupported" if DYNAMIC_IDS.include?(t)
      computed = true if SYMBOL_IDS.include?(t)
      next unless SCANNED.include?(t)
      raise Refusal, "#{t}: taking an API function address is outside the literal scanner subset" unless tokens[i+1] == "("
      args, = arguments(tokens, i+2)
      case t
      when "rb_intern", "rb_intern2"
        raise Refusal, "#{t}: invalid argument count" unless args.length == (t == "rb_intern2" ? 2 : 1)
        value = c_string(args[0], t)
        if t == "rb_intern2"
          size = args[1]
          raise Refusal, "rb_intern2: length must be a nonnegative integer literal" unless size.length == 1 && size[0] =~ /\A[0-9]+\z/
          len = Integer(size[0], 10)
          raise Refusal, "rb_intern2: length exceeds string literal" if len > value.bytesize
          value = value.byteslice(0, len)
        end
        names << value
      when "rb_funcall", "rb_funcallv", "rb_block_call"
        a = args[2]
        # rb_funcallv with a count it computes (sqlite3's aggregator hands on
        # what SQLite gave it) is a spread send: the stub takes the arguments
        # as one Array, as rb_apply's does
        if t == "rb_funcallv" && args.length == 4 && !(a && a.length == 1 && a[0] =~ /\A[0-9]+\z/)
          spread = true
          next
        end
        raise Refusal, "#{t}: arity must be a nonnegative integer literal" unless a && a.length == 1 && a[0] =~ /\A[0-9]+\z/
        arity = Integer(a[0], 10)
        expected = t == "rb_funcall" ? 3 + arity : t == "rb_funcallv" ? 4 : 6
        raise Refusal, "#{t}: argument count does not match literal arity" unless args.length == expected
        arities << arity
      when "rb_apply"
        raise Refusal, "rb_apply: invalid argument count" unless args.length == 3
        spread = true
      when "rb_iv_get", "rb_iv_set"
        raise Refusal, "#{t}: invalid argument count" unless args.length == (t == "rb_iv_get" ? 2 : 3)
        name = c_string(args[1], t)
        ivars << name unless name.match?(HIDDEN_IVAR)
      when "rb_ivar_defined"
        raise Refusal, "rb_ivar_defined: invalid argument count" unless args.length == 2
        id = args[1]
        unless id.length == 4 && id[0] == "rb_intern" && id[1] == "(" && id[3] == ")" && c_string([id[2]], t).match?(HIDDEN_IVAR)
          raise Refusal, "rb_ivar_defined: only a literal hidden instance variable (rb_intern(\"-name\")) is supported"
        end
      when "rb_eval_string"
        raise Refusal, "rb_eval_string: expected a literal string" unless args.length == 1
        evals << c_string(args[0], t)
      when "rb_const_get", "rb_const_get_at"
        constants = true
      end
    end
    # ID-based ivar operations use the literal intern pool as well. Conservatively
    # include every @name; their receiver is intentionally boxed and polymorphic.
    ivars.concat(names.select { |n| n.start_with?("@") })
    ivars.each do |name|
      raise Refusal, "invalid literal instance variable #{name.inspect}" unless name =~ /\A@[A-Za-z_][A-Za-z_0-9]*\z/
    end
    [names.uniq.sort, arities.uniq.sort,
     {"ivars" => ivars.uniq.sort, "evals" => evals.uniq.sort, "constant_reads" => constants, "computed_ids" => computed,
      "spread_sends" => spread}]
  end

  def write_atomic(path, bytes)
    temp = "#{path}.tmp.#{$$}"
    File.write(temp, bytes)
    File.rename(temp, path)
  ensure
    File.delete(temp) if temp && File.exist?(temp)
  end

  def validate_flags(flags)
    safe = /\A(?:-(?:I|D|U).+|-std=(?:c|gnu)(?:89|90|99|11|17|18|23)|-O[0-3sg]|-g(?:gdb)?[0-3]?|-pipe|-pthread|-f(?:PIC|pic|no-common|no-fast-math|declspec|stack-protector-strong|stack-clash-protection|cf-protection(?:=(?:full|branch|return|none))?|(?:file|debug|macro)-prefix-map=.+|no-strict-aliasing|no-strict-overflow|wrapv|no-omit-frame-pointer|visibility=(?:hidden|default))|-W[A-Za-z0-9_=,.-]+)\z/
    raise Refusal, "unsupported C extension compiler flag" unless flags.all? { |flag| flag.match?(safe) }
    flags
  end

  # Rename undefined symbols in a recorder-only copy. Retained runtime
  # objects and their preprocessor decisions stay exactly as compiled.
  def redirect_imports(input, output, replacements)
    bytes=File.binread(input)
    if bytes.byteslice(0,4)=="\xcf\xfa\xed\xfe".b
      offset=32; symtab=nil
      bytes.byteslice(16,4).unpack1('V').times do
        kind,size=bytes.byteslice(offset,8).unpack('V2')
        symtab=offset if kind==2
        offset+=size
      end
      raise Refusal,'recorder object has no symbol table' unless symtab
      symbols,count,strings,length=bytes.byteslice(symtab+8,16).unpack('V4')
      names=bytes.byteslice(strings,length)
      count.times do |index|
        entry=symbols+index*16
        next unless bytes.getbyte(entry+4)&0x0e==0
        position=bytes.byteslice(entry,4).unpack1('V')
        name=names.byteslice(position..).split("\0",2).first
        replacement=replacements[name.delete_prefix('_')]
        next unless replacement
        bytes[entry,4]=[names.bytesize].pack('V')
        names << '_'+replacement+"\0"
      end
      bytes[symtab+16,8]=[bytes.bytesize,names.bytesize].pack('V2')
      bytes << names
    elsif bytes.byteslice(0,6)=="\x7fELF\x02\x01".b
      sections=bytes.byteslice(40,8).unpack1('Q<')
      size=bytes.byteslice(58,2).unpack1('v')
      count=bytes.byteslice(60,2).unpack1('v')
      count.times do |index|
        section=sections+index*size
        next unless bytes.byteslice(section+4,4).unpack1('V')==2
        strings_section=sections+bytes.byteslice(section+40,4).unpack1('V')*size
        strings=bytes.byteslice(strings_section+24,8).unpack1('Q<')
        length=bytes.byteslice(strings_section+32,8).unpack1('Q<')
        names=bytes.byteslice(strings,length)
        symbols=bytes.byteslice(section+24,8).unpack1('Q<')
        symbol_bytes=bytes.byteslice(section+32,8).unpack1('Q<')
        stride=bytes.byteslice(section+56,8).unpack1('Q<')
        (symbol_bytes/stride).times do |slot|
          entry=symbols+slot*stride
          next unless bytes.byteslice(entry+6,2).unpack1('v')==0
          position=bytes.byteslice(entry,4).unpack1('V')
          replacement=replacements[names.byteslice(position..).split("\0",2).first]
          next unless replacement
          bytes[entry,4]=[names.bytesize].pack('V');names << replacement+"\0"
        end
        bytes[strings_section+24,16]=[bytes.bytesize,names.bytesize].pack('Q<2')
        bytes << names
      end
    else
      raise Refusal,'native recorder imports require a little-endian ELF64 or Mach-O64 object'
    end
    File.binwrite(output,bytes)
  end

  def callable_symbols(tokens)
    names = []
    tokens.each_with_index do |token, index|
      names << token if tokens[index + 1] == '(' && token.match?(/\A[A-Za-z_][A-Za-z_0-9]*\z/)
      # glibc redirects some function declarations with an assembler name,
      # e.g. strerror_r(...) __asm__("" "__xpg_strerror_r"). A data
      # declaration, including a function pointer, has no function name
      # immediately before the balanced argument list.
      next unless %w[__asm__ __asm asm].include?(token) && tokens[index - 1] == ')'
      position = index - 2
      depth = 1
      while position >= 0 && depth > 0
        depth += 1 if tokens[position] == ')'
        depth -= 1 if tokens[position] == '('
        position -= 1
      end
      function = position >= 0 ? tokens[position] : ''
      next unless depth == 0 && names.include?(function) && !%w[__attribute__ __attribute].include?(function)
      next unless tokens[index + 1] == '('
      position = index + 2
      symbol = ''
      while position < tokens.length && tokens[position].match?(/\A"[A-Za-z_0-9]*"\z/)
        symbol += tokens[position][1...-1]
        position += 1
      end
      next unless tokens[position] == ')' && symbol.match?(/\A[A-Za-z_][A-Za-z_0-9]*\z/)
      symbol = symbol.delete_prefix('_') if RUBY_PLATFORM.include?('darwin')
      names << symbol
    end
    names
  end

  def record(name:, init:, sources:, output:, declarations: nil, object_archive: nil, cflags: [], cc: ENV.fetch("CC", "cc"), threaded: false, libs: nil, init_imports: [])
    raise Refusal, "invalid extension name" unless name =~ /\A[A-Za-z_][A-Za-z_0-9]*\z/
    raise Refusal, "invalid Init symbol" unless init =~ /\AInit_[A-Za-z_0-9]+\z/
    raise Refusal, "at least one C source is required" if sources.empty?
    paths = [output, declarations, object_archive].compact.map { |p| File.expand_path(p) }
    raise Refusal, "artifacts need distinct output paths" unless paths.uniq.length == paths.length
    compiler = Shellwords.split(cc)
    raise Refusal, "empty C compiler command" if compiler.empty?
    # Instrumentation/LTO obscure the import check; build the recorder from
    # ordinary objects. User flags cannot replace its header or compiler action.
    validate_flags(cflags)
    raise Refusal,'invalid native initializer import' unless init_imports.all? { |symbol| symbol.match?(/\A[A-Za-z_][A-Za-z_0-9]*\z/) }
    raise Refusal,'native initializer imports require explicit libraries' if !init_imports.empty? && (libs.nil? || libs.empty?)
    Dir.mktmpdir("spinel-cext-record-") do |dir|
      flags = ["-std=c11", "-O0", "-DSP_CEXT_RECORDER", "-I#{ROOT}/include", *cflags]
      flags += ["-DSP_THREADS", "-ftls-model=initial-exec"] if threaded
      objects = []; names = []; arities = []; ivars = []; evals = []; constant_reads = false; computed_ids = false; spread_sends = false; callable = []
      sources.each_with_index do |source, i|
        source = File.expand_path(source)
        raise Refusal, "missing C source #{source}" unless File.file?(source)
        preprocessed=command(*compiler,*flags,"-E",source)
        tokens=preprocessed.scan(TOKEN)
        callable.concat(callable_symbols(tokens))
        ids, argc, bridge = scan(preprocessed)
        names.concat(ids); arities.concat(argc)
        ivars.concat(bridge["ivars"]); evals.concat(bridge["evals"])
        constant_reads ||= bridge["constant_reads"]
        computed_ids ||= bridge["computed_ids"]
        spread_sends ||= bridge["spread_sends"]
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
      # (the GOT is the linker's: PIE code names it for a global another unit defines)
      unknown = (undefined.uniq - defined - LIBC - %w[_GLOBAL_OFFSET_TABLE_]).grep_v(OUTLINE_ATOMICS)
      imports=[]; links=[]; record_objects=objects
      unless unknown.empty?
        raise Refusal, "#{unknown.sort.join(', ')}: external API is outside the deterministic recorder subset" if libs.nil?
        invalid=unknown-callable
        raise Refusal,"#{invalid.sort.join(', ')}: imported native data is outside the recorder subset" unless invalid.empty?
        links=libs.map { |lib| lib.start_with?('-') || File.file?(lib) ? lib : '-l'+lib }
        probe=File.join(dir,'import-probe.c')
        probe_declarations=unknown.map { |symbol| "extern void #{symbol}(void);" }.join("\n")
        File.write(probe,probe_declarations+"\nvoid (*volatile imports[])(void)={"+unknown.join(',')+"};\nint main(void){return imports[0]==0;}\n")
        command(*compiler,probe,*links,'-o',File.join(dir,'import-probe'))
        stub=File.join(dir,'imports.c')
        replacements={}
        (unknown-init_imports).each_with_index { |symbol,index| replacements[symbol]="sp_cext_native_import_#{index}" }
        record_objects=objects.each_with_index.map do |object,index|
          copy=File.join(dir,"record-extension#{index}.o")
          redirect_imports(object,copy,replacements);copy
        end
        File.write(stub,"#include \"recorder.h\"\n"+replacements.map { |symbol,replacement| "void #{replacement}(void){sp_cext_record_external(\"#{symbol}\");}" }.join("\n"))
        object=File.join(dir,'imports.o')
        command(*compiler,'-I'+ROOT+'/tools/cext','-c',stub,'-o',object)
        imports << object
      end
      main = File.join(dir, "main.c")
      File.write(main, "#include \"recorder.h\"\nvoid #{init}(void);\nint main(void) { sp_cext_record_begin(\"#{name}\"); #{init}(); sp_cext_record_finish(); return 0; }\n")
      exe = File.join(dir, "record")
      archive = File.join(dir, "libspinel_cext_rec.a")
      command("ar", "rcs", archive, rec)
      command(*compiler, *flags, "-I#{ROOT}/tools/cext", main, *record_objects, *imports, archive, *(init_imports.empty? ? [] : links), "-o", exe)
      # Files keep capture bounded by the child timeout without depending on
      # Open3's streaming API, which the self-hosted project tool does not have.
      out_path = File.join(dir, "events.jsonl")
      err_path = File.join(dir, "events.err")
      pid = Process.spawn(exe, pgroup: true, in: File::NULL, out: out_path, err: err_path)
      wait = Thread.new { Process.waitpid2(pid)[1] }
      unless wait.join(10)
        begin
          Process.kill("KILL", -pid)
        rescue Errno::ESRCH
          # The child finished between the timeout and the signal.
        end
        wait.join
        raise Refusal, "#{init}: recorder exceeded 10 seconds"
      end
      status = wait.value
      unless status.success?
        message = File.read(err_path).strip
        message = "#{init}: recorder exited with #{status}" if message.empty?
        raise Refusal, message
      end
      events = File.readlines(out_path).map { |line| JSON.parse(line) }
      manifest = {"version" => 1, "extension" => name, "init" => init,
                  "definitions" => events, "literal_ids" => names.uniq.sort,
                  "funcall_arities" => arities.uniq.sort,
                  "ivars" => ivars.uniq.sort, "evals" => evals.uniq.sort, "constant_reads" => constant_reads}
      manifest["computed_ids"] = true if computed_ids
      manifest["spread_sends"] = true if spread_sends
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
             when "reference" then [d["path"]]
             when "method" then d.values_at("owner", "name", "scope", "visibility", "arity", "function")
             when "allocator" then d.values_at("owner", "function")
             when "alias" then d.values_at("owner", "name", "original")
             when "attribute" then d.values_at("owner", "name", "read", "write")
             when "include", "extend" then d.values_at("owner", "module")
             when "undef_method" then d.values_at("owner", "name")
             when "undef_allocator" then [d["owner"]]
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
    manifest.fetch("ivars", []).each { |ivar| lines << "__cext_ivar(#{ivar.dump})" }
    manifest.fetch("evals", []).each { |code| lines << "__cext_eval(#{code.dump})" }
    lines << "__cext_constant_reads()" if manifest["constant_reads"]
    manifest["literal_ids"].each do |name|
      next if name.start_with?("@") || name.match?(HIDDEN_IVAR)
      manifest["funcall_arities"].each { |arity| lines << "__cext_stub(0, #{name.dump}, #{arity})" }
      if manifest["constant_reads"] && name =~ /\A[A-Z][A-Za-z_0-9]*\z/
        lines << "__cext_stub(3, #{name.dump}, 0)"
      end
    end
    manifest.fetch("ivars", []).each do |name|
      lines << "__cext_stub(1, #{name.dump}, 0)"
      lines << "__cext_stub(2, #{name.dump}, 1)"
    end
    manifest.fetch("evals", []).each { |code| lines << "__cext_stub(4, #{code.dump}, 0)" }
    if manifest["spread_sends"]
      manifest["literal_ids"].each do |name|
        next if name.start_with?("@") || name.match?(HIDDEN_IVAR)
        lines << "__cext_stub(6, #{name.dump}, 1)"
      end
    end
    if manifest["computed_ids"]
      manifest["funcall_arities"].each { |arity| lines << "__cext_stub(5, \"\", #{arity})" }
      lines << "__cext_stub(7, \"\", 1)" if manifest["spread_sends"]
    end
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
