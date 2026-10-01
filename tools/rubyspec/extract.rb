#!/usr/bin/env ruby
# extract.rb -- project ruby/spec files onto single-example spinel programs.
#
# Usage: ruby tools/rubyspec/extract.rb SPEC_DIR OUT_DIR [file_glob]
#
# One extracted program per `it` block: mspec_lite.rb + the fixture files the
# spec loads (pruned to what the example names, see below) + the spec's
# top-level prelude (helper classes/defs) + the enclosing describes'
# before(:each) bodies + the example body + after(:each) bodies + an
# MSPEC-DONE trailer.
# Example granularity is the point: one eval-using example must not cost the
# whole file its measurement.
#
# Line-based structural scan (ruby/spec style is uniform 2-space indent); an
# example whose block structure we fail to track is emitted anyway and will
# surface as a compile reject -- the runner's HARNESS-SKEW check (running the
# same program under CRuby) catches any extraction that changed meaning.
#
# Rewrites applied (source-compatibility shims for spinel gaps, documented in
# mspec_lite.rb): ScratchPad -> a local `scratch_pad`; `x.should be_close(..)`
# -> the chain form `x.should.be_close(..)`; `x.should.respond_to?(:m)` ->
# `x.respond_to?(:m).should == true`.
#
# Fixtures: a spec's `require_relative '.../fixtures/<name>'` is inlined into
# each of its examples, after the files that fixture itself require_relative's.
# Most of ruby/spec's fixture classes live there, and an example that names
# one is otherwise a NameError. A fixture file is pruned per example:
# spinel compiles every method a program defines, so one fixture class the
# example never touches could make it a REJECT. See fixture_text.

# ruby/spec sources are UTF-8. Under an empty or C locale Ruby read them as
# US-ASCII, and the first non-ASCII line raised mid-glob, leaving every later
# spec file unextracted.
Encoding.default_external = Encoding::UTF_8

SPEC_DIR = ARGV[0] or abort "usage: extract.rb SPEC_DIR OUT_DIR [glob]"
OUT_DIR  = ARGV[1] or abort "usage: extract.rb SPEC_DIR OUT_DIR [glob]"
GLOB     = ARGV[2] || "**/*_spec.rb"
LITE     = File.read(File.join(__dir__, "mspec_lite.rb"))

require "prism"

SPINEL_VERSION = [4, 0]   # the CRuby level spinel targets, for version guards

require "fileutils"
FileUtils.mkdir_p(OUT_DIR)

def version_guard_active?(kind, args)
  # ruby_version_is "3.0" / "3.0"..."3.4" -- include body if 4.0 is in range.
  lo = args[/["']([\d.]+)["']/, 1]
  hi = args[/\.\.\.?\s*["']([\d.]+)["']/, 1]
  excl = args.include?("...")
  v  = SPINEL_VERSION
  cmp = ->(s) { s.split(".").map(&:to_i) }
  ok = true
  ok &&= (cmp.(lo) <=> v) <= 0 if lo
  ok &&= excl ? (v <=> cmp.(hi)) < 0 : (v <=> cmp.(hi)) <= 0 if hi
  kind == "ruby_version_is" ? ok : hi ? !ok : !lo || (v <=> cmp.(lo)) > 0
end

# fixture_files(path, seen): the fixture file at path, after the fixtures it
# require_relative's itself, each once per spec file.
def fixture_files(path, seen)
  return [] if seen[path] || !File.file?(path)
  seen[path] = true
  out = []
  File.foreach(path, mode: "rb") do |l|   # a fixture need not be UTF-8
    next unless l =~ /\A\s*require_relative\s+["']([^"']+)["']/n
    dep = File.expand_path($1.delete_suffix(".rb") + ".rb", File.dirname(path))
    out.concat(fixture_files(dep, seen))
  end
  out << path
end

# fixture_chunks(src): split a fixture's top level into the pieces an example
# may or may not need. A top-level module is a container (`module
# KernelSpecs`): its children are pieces of their own, and its header and
# footer are kept whatever is pruned from it. A class, module, def or
# constant is a :def piece, named. Any other statement (a call, an include,
# `class << obj`) is a :stmt piece. It is kept when it names no :def piece
# and defines nothing; else when a :def piece it names is kept
# (`class << CS_SINGLETON1` goes with CS_SINGLETON1), or when the example
# names a method or constant it defines. The text between pieces is :glue,
# always kept. Returns [[name or nil, text, kind, names it defines]] in
# source order, or nil.
def fixture_chunks(src)
  res = Prism.parse(src)
  return nil unless res.success?
  name_of = lambda do |n|
    case n
    when Prism::ClassNode, Prism::ModuleNode then n.constant_path.slice.split("::").last
    when Prism::DefNode then n.name.to_s
    when Prism::ConstantWriteNode, Prism::ConstantOrWriteNode then n.name.to_s
    end
  end
  # the methods and constants a statement defines inside itself (`class <<
  # self; def m`), which an example can name as it names a :def piece
  inner_names = lambda do |n, acc = []|
    acc << n.name.to_s if n.is_a?(Prism::DefNode) || n.is_a?(Prism::ConstantWriteNode)
    acc << n.constant_path.slice.split("::").last if n.is_a?(Prism::ClassNode) || n.is_a?(Prism::ModuleNode)
    n.compact_child_nodes.each { |c| inner_names.(c, acc) }
    acc
  end
  piece = lambda do |n, top = false|
    nm = name_of.(n)
    # a reopened builtin at the top level (`class Class; def m`) is needed for
    # the methods it adds, not because the example says Class
    nm = nil if top && nm && (n.is_a?(Prism::ClassNode) || n.is_a?(Prism::ModuleNode)) &&
                n.constant_path.is_a?(Prism::ConstantReadNode) && Object.const_defined?(nm)
    [nm, src.byteslice(n.location.start_offset, n.location.length), nm ? :def : :stmt, nm ? [] : inner_names.(n).uniq]
  end
  glue = ->(from, to) { [nil, src.byteslice(from, to - from), :glue, []] }
  out = []
  pos = 0
  res.value.statements.body.each do |top|
    out << glue.(pos, top.location.start_offset)
    pos = top.location.start_offset + top.location.length
    body = top.is_a?(Prism::ModuleNode) && top.body.is_a?(Prism::StatementsNode) ? top.body.body : nil
    if body.nil? || body.empty?
      out << piece.(top, true)
      next
    end
    inner = top.location.start_offset
    body.each do |c|
      out << glue.(inner, c.location.start_offset)
      out << piece.(c)
      inner = c.location.start_offset + c.location.length
    end
    out << glue.(inner, pos)
  end
  out << glue.(pos, src.bytesize)
end

# fixture_text(src, text): src keeping only the pieces text needs: the :def
# pieces it names, the :stmt pieces that go with them, and what those name,
# transitively. A fixture Prism cannot parse is kept whole, and one that is
# not valid UTF-8 whole or not at all (the CRuby oracle judges the result).
def fixture_text(src, text)
  # the files a fixture loads are inlined ahead of it (fixture_files), and the
  # extracted program has no directory to load anything else from
  src = src.b.gsub(/^[ \t]*require(?:_relative)?[ \t(].*$/n, "").force_encoding(Encoding::UTF_8)
  unless src.valid_encoding?
    # a fixture in another encoding (iso-8859-9) is inlined whole when the
    # example names a class, module or method it defines, and left out else
    names = src.b.scan(/^\s*(?:class|module|def)\s+(?:self\.)?([A-Za-z_]\w*[?!]?)/n).flatten.uniq
    return names.any? { |n| text =~ /(?<![\w@$])#{Regexp.escape(n.force_encoding("UTF-8"))}(?![\w?!])/ } ? src : ""
  end
  chunks = fixture_chunks(src) or return src
  word = ->(name) { /(?<![\w@$])#{Regexp.escape(name)}(?![\w?!])/ }
  defs = chunks.each_index.select { |i| chunks[i][2] == :def }
  # the :def pieces each :stmt names; a :stmt that names none is always kept
  names = {}
  chunks.each_with_index do |(_, body, kind, _), i|
    names[i] = defs.select { |d| body =~ word.(chunks[d][0]) } if kind == :stmt
  end
  kept = chunks.each_with_index.map { |(_, _, kind, own), i| kind == :glue || (kind == :stmt && names[i].empty? && own.empty?) }
  look = text + "\n" + chunks.each_index.select { |i| kept[i] }.map { |i| chunks[i][1] }.join("\n")
  loop do
    grew = false
    chunks.each_with_index do |(name, body, kind, own), i|
      next if kept[i]
      need = kind == :def ? look =~ word.(name) :
             names[i].any? { |d| kept[d] } || own.any? { |m| look =~ word.(m) }
      next unless need
      kept[i] = true; look += "\n" + body; grew = true   # apart, so names stay words
    end
    break unless grew
  end
  chunks.each_with_index.map { |(_, body, _, _), i| kept[i] ? body : "" }.join
end

def rewrite(line)
  line = line.gsub(/ScratchPad\.record\s+(.+)$/) { "scratch_pad = #{$1}" }
  line = line.gsub(/ScratchPad\.record\((.+)\)/) { "scratch_pad = #{$1}" }
  line = line.gsub(/ScratchPad\s*<</, "scratch_pad <<")
  line = line.gsub("ScratchPad.recorded", "scratch_pad")
  line = line.gsub("ScratchPad.clear", "scratch_pad = nil")
  # mspec's be_close matcher, in the chain form mspec_lite implements
  line = line.gsub(/\.should(_not)? be_close\(/) { ".should#{$1}.be_close(" }
  # spinel answers respond_to? only for a name it sees at compile time, which
  # a predicate on the wrapper would pass on as a variable: the receiver is
  # asked directly, with the literal, and the wrapper compares the answer
  line = line.sub(/\.should(_not)?\.respond_to\?(\((?:[^()]|\g<2>)*\))(\s*(?:#.*)?)$/) do
    ".respond_to?#{$2}.should == #{$1 ? "false" : "true"}#{$3}"
  end
  # spinel never dispatches a user `equal?` (it compiles identity in place),
  # so `x.should.equal?(y)` checked nothing either
  line = line.gsub(/\.should(_not)?\.equal\?(?=[( ])/) { ".should#{$1}.same" }
  # spinel does not dispatch a user `==` whose argument is a Hash, so
  # `x.should == {a: 1}` checked nothing: the expectation is called by name
  # instead. Only an operand that ends on its line is rewritten, and none a
  # pair of parentheses would change (a modifier, and/or, a heredoc).
  if (m = line.match(/\A(.*\.should(?:_not)?) == (.*?)(\s*)\z/m)) && one_line_operand?(m[2])
    line = "#{m[1]}.eq(#{m[2]})#{m[3]}"
  end
  line
end

def one_line_operand?(rhs)
  return false if rhs.empty? || rhs.include?(".should")
  return false if rhs =~ /\b(if|unless|while|until|rescue|and|or|not|do)\b/ || rhs =~ /<<[~-]?["'A-Z_]/
  return false if rhs =~ /#(?!\{)/ || rhs =~ /[,\\(\[{|&+\-*\/=<>.?:]\z/
  depth = 0
  bare = rhs.gsub(/"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'/, '""')
  return false if bare.include?(";")
  bare.each_char do |ch|
    depth += 1 if "([{".include?(ch)
    depth -= 1 if ")]}".include?(ch)
    return false if depth < 0
  end
  depth.zero?
end

total = 0
fx_src = {}             # fixture path -> source, read once per run
Dir.glob(GLOB, base: SPEC_DIR).sort.each do |rel|
  path = File.join(SPEC_DIR, rel)
  base = rel.delete_suffix(".rb").tr("/", "-")
  lines = File.readlines(path)

  prelude = []          # top-level lines outside any block
  stack = []            # open blocks: {kind:, desc:, befores:[], afters:[], skip:}
  example = nil         # {desc:, body:[], line:}
  collecting = nil      # :before / :after -> currently filling that list
  n_in_file = 0
  fixtures = []         # fixture files the spec loads, in load order
  fx_seen = {}

  block_open = /\b(do|\{)\s*(\|[^|]*\|)?\s*$/
  lines.each_with_index do |raw, ln|
    line = raw.chomp
    s = line.strip.sub(/\A(?:"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|[^"'])*?\bdo\K\s+#.*/, "")
    if !example && stack.empty? && s =~ /\Arequire_relative\s+["']([^"']*fixtures\/[^"']+)["']/
      fx = File.expand_path($1.delete_suffix(".rb") + ".rb", File.dirname(path))
      fixtures.concat(fixture_files(fx, fx_seen))
    end
    next if s.start_with?("require_relative", "require ")

    if example
      # inside an it block: track nesting depth via do/end pairs
      if s =~ /^(it|describe|context)\b/ && false; end
      example[:depth] += 1 if s =~ block_open || s =~ /^(begin|def|class|module|case|if|unless|while|until|for)\b/ && s !~ /\bend\b/
      if s == "end" || s =~ /^end\b/
        if example[:depth].zero?
          # emit
          out = +""
          out << LITE << "\n"
          out << "scratch_pad = nil\n"
          unless fixtures.empty?
            text = prelude.join + stack.map { |b| b[:befores].join + b[:afters].join }.join + example[:body].join
            fixtures.each { |fx| out << fixture_text(fx_src[fx] ||= File.read(fx), text) << "\n" }
          end
          out << prelude.join
          stack.each { |b| out << b[:befores].join }
          out << example[:body].join
          stack.reverse_each { |b| out << b[:afters].join }
          out << "\nputs \"MSPEC-DONE pass=\#{$spec_pass} fail=\#{$spec_fail}\"\n"
          n_in_file += 1
          name = format("%s__%03d", base, n_in_file)
          desc = (stack.map { |b| b[:desc] } + [example[:desc]]).compact.join(" ")
          File.write(File.join(OUT_DIR, name + ".rb"),
                     "# #{rel}:#{example[:line]} -- #{desc}\n" + out)
          total += 1
          example = nil
        else
          example[:depth] -= 1
          example[:body] << rewrite(raw)
        end
      else
        example[:body] << rewrite(raw)
      end
      next
    end

    skip = stack.any? { |b| b[:skip] }

    case s
    when /^(describe|context)\b(.*)/ 
      desc = s[/["'](.*?)["']/, 1]
      stack << { kind: "describe", desc: desc, befores: [], afters: [], skip: skip }
    when /^(ruby_version_is|ruby_bug)\b(.*?)do\s*$/
      stack << { kind: $1, desc: nil, befores: [], afters: [], skip: skip || !version_guard_active?($1, $2) }
    when /^platform_is_not\b.*do\s*$/
      stack << { kind: "platform", desc: nil, befores: [], afters: [], skip: skip }  # linux: not-guards usually about windows; keep body
    when /^platform_is\b.*do\s*$/
      keep = s.include?("linux") || s.include?(":wordsize") 
      stack << { kind: "platform", desc: nil, befores: [], afters: [], skip: skip || !keep }
    when /^(before|after)\b/
      which = $1 == "before" ? :before : :after
      if s =~ /\{(.*)\}\s*$/    # single-line brace form
        body = rewrite($1.strip) + "\n"
        (which == :before ? stack.last[:befores] : stack.last[:afters]) << body if stack.any? && !skip
      elsif s =~ /do\s*$/
        collecting = which
      end
    when /^it\s+["'](.*?)["']\s+do\s*$/
      unless skip
        example = { desc: $1, body: [], depth: 0, line: ln + 1 }
      else
        stack << { kind: "skipped-it", desc: nil, befores: [], afters: [], skip: true }
      end
    when "end"
      if collecting
        collecting = nil
      else
        closed = stack.pop
        prelude << raw if closed && closed[:helper] && !closed[:skip]
      end
    else
      if collecting
        (collecting == :before ? stack.last[:befores] : stack.last[:afters]) << rewrite(raw) unless skip || stack.empty?
      elsif stack.empty?
        prelude << rewrite(raw) unless s.empty? || s.start_with?("#")
      end
      # helper definitions inside a describe: take complete def/class blocks
      # only; stray expression fragments would corrupt the prelude.
      if !collecting && !stack.empty? && s =~ /^(def|class|module)\b/
        stack << { kind: "helper", desc: nil, befores: [], afters: [], skip: skip, helper: true }
        prelude << rewrite(raw) unless skip
      elsif !collecting && !stack.empty? && stack.last[:helper] && !skip
        prelude << rewrite(raw)
      end
    end
  end
  # single-line before { } handling above also needs plain-before matching; keep v1 simple.
end

puts "extracted #{total} examples into #{OUT_DIR}"
