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
# KernelSpecs`): its class/module/def/constant children are chunks of their
# own, and it is kept whatever is pruned from it. A top-level class, def or
# constant is one chunk. Anything else (a call, an include, a require) is kept.
# Returns [[name or nil, text]], in source order; nil means always kept.
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
  piece = ->(n) { src.byteslice(n.location.start_offset, n.location.length) }
  out = []
  pos = 0
  res.value.statements.body.each do |top|
    out << [nil, src.byteslice(pos, top.location.start_offset - pos)]
    pos = top.location.start_offset + top.location.length
    body = top.is_a?(Prism::ModuleNode) && top.body.is_a?(Prism::StatementsNode) ? top.body.body : nil
    if body.nil? || body.empty?
      out << [name_of.(top), piece.(top)]
      next
    end
    # the container's header and footer stay; its children are chunks
    inner = top.location.start_offset
    body.each do |c|
      out << [nil, src.byteslice(inner, c.location.start_offset - inner)]
      out << [name_of.(c), piece.(c)]
      inner = c.location.start_offset + c.location.length
    end
    out << [nil, src.byteslice(inner, pos - inner)]
  end
  out << [nil, src.byteslice(pos, src.bytesize - pos)]
end

# fixture_text(src, text): src keeping only the chunks text names, and the
# chunks those name, transitively. A fixture Prism cannot parse, or that is
# not valid UTF-8, is kept whole (the CRuby oracle judges the result).
def fixture_text(src, text)
  # the files a fixture loads are inlined ahead of it (fixture_files), and the
  # extracted program has no directory to load anything else from
  src = src.b.gsub(/^[ \t]*require(?:_relative)?[ \t(].*$/n, "").force_encoding(Encoding::UTF_8)
  return src unless src.valid_encoding?
  chunks = fixture_chunks(src) or return src
  kept = chunks.map { |name, _| name.nil? }
  look = text + chunks.select { |name, _| name.nil? }.map(&:last).join
  loop do
    grew = false
    chunks.each_with_index do |(name, body), i|
      next if kept[i] || look !~ /(?<![\w@$])#{Regexp.escape(name)}(?![\w])/
      kept[i] = true; look += body; grew = true
    end
    break unless grew
  end
  chunks.each_with_index.map { |(_, body), i| kept[i] ? body : "" }.join
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
  line
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
