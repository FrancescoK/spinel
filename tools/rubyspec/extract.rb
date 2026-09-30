#!/usr/bin/env ruby
# extract.rb -- project ruby/spec files onto single-example spinel programs.
#
# Usage: ruby tools/rubyspec/extract.rb SPEC_DIR OUT_DIR [file_glob]
#
# One extracted program per `it` block: mspec_lite.rb + the spec's top-level
# prelude (fixture classes/defs) + the enclosing describes' before(:each)
# bodies + the example body + after(:each) bodies + an MSPEC-DONE trailer.
# Example granularity is the point: one eval-using example must not cost the
# whole file its measurement.
#
# Line-based structural scan (ruby/spec style is uniform 2-space indent); an
# example whose block structure we fail to track is emitted anyway and will
# surface as a compile reject -- the runner's HARNESS-SKEW check (running the
# same program under CRuby) catches any extraction that changed meaning.
#
# Rewrites applied (source-compatibility shims for spinel gaps, documented in
# mspec_lite.rb): ScratchPad -> a local `scratch_pad`.

# ruby/spec sources are UTF-8. Under an empty or C locale Ruby read them as
# US-ASCII, and the first non-ASCII line raised mid-glob, leaving every later
# spec file unextracted.
Encoding.default_external = Encoding::UTF_8

SPEC_DIR = ARGV[0] or abort "usage: extract.rb SPEC_DIR OUT_DIR [glob]"
OUT_DIR  = ARGV[1] or abort "usage: extract.rb SPEC_DIR OUT_DIR [glob]"
GLOB     = ARGV[2] || "**/*_spec.rb"
LITE     = File.read(File.join(__dir__, "mspec_lite.rb"))

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

def rewrite(line)
  line = line.gsub(/ScratchPad\.record\s+(.+)$/) { "scratch_pad = #{$1}" }
  line = line.gsub(/ScratchPad\.record\((.+)\)/) { "scratch_pad = #{$1}" }
  line = line.gsub(/ScratchPad\s*<</, "scratch_pad <<")
  line = line.gsub("ScratchPad.recorded", "scratch_pad")
  line = line.gsub("ScratchPad.clear", "scratch_pad = nil")
  line
end

total = 0
Dir.glob(GLOB, base: SPEC_DIR).sort.each do |rel|
  path = File.join(SPEC_DIR, rel)
  base = rel.delete_suffix(".rb").tr("/", "-")
  lines = File.readlines(path)

  prelude = []          # top-level lines outside any block
  stack = []            # open blocks: {kind:, desc:, befores:[], afters:[], skip:}
  example = nil         # {desc:, body:[], line:}
  collecting = nil      # :before / :after -> currently filling that list
  n_in_file = 0

  block_open = /\b(do|\{)\s*(\|[^|]*\|)?\s*$/
  lines.each_with_index do |raw, ln|
    line = raw.chomp
    s = line.strip.sub(/\A(?:"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|[^"'])*?\bdo\K\s+#.*/, "")
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
