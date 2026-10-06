#!/usr/bin/env ruby
# frozen_string_literal: true
#
# lib/sp_poly_cold.c includes spinel_rt.h as a host and holds functions the
# header used to define `static` in every generated unit. Compiled once, it must
# behave as the generated unit's own copy would, which holds only while:
#
#   1. its code does not depend on the integer-overflow mode. The generated unit
#      is built with -DSP_INT_OVERFLOW_MODE_{RAISE,WRAP,PROMOTE}, the library
#      once; the object has to be byte-identical under all of them.
#   2. nothing it can reach is a writable static of its own. A private copy of a
#      variable the generated unit sets (a hook, the exception stack) stays at its
#      initial value, and the optimizer folds the test of an unwritten static away,
#      so a symbol check alone misses it. The unit is built at -O0 with one section
#      per function and per variable, and every relocation reachable from an
#      exported function is followed.
#
# usage: ruby tools/poly_cold_check.rb [CC...]   (CC may be several words, e.g. `ccache cc`)

require "open3"
require "tmpdir"
require "digest"

cc = (ARGV.empty? ? [ENV["CC"] || "cc"] : ARGV).join(" ").split
inc = %w[-Ilib -Ilib/regexp -Ilib/regexp/shim]
src = "lib/sp_poly_cold.c"
env = { "LC_ALL" => "C" }

def run(env, *cmd)
  out, err, st = Open3.capture3(env, *cmd)
  abort "poly-cold-test: #{cmd.join(' ')} failed:\n#{err}" unless st.success?
  out
end

ok = true
Dir.mktmpdir("poly-cold") do |dir|
  # 1. mode independence, at the optimization level the library ships with
  digests = {}
  ["", "-DSP_INT_OVERFLOW_MODE_RAISE", "-DSP_INT_OVERFLOW_MODE_WRAP", "-DSP_INT_OVERFLOW_MODE_PROMOTE"].each do |flag|
    o = File.join(dir, "m.o")
    run(env, *cc, "-O2", "-w", "-c", *flag.split, *inc, src, "-o", o)
    text = run(env, "objdump", "-d", "--no-show-raw-insn", o).lines.drop(3).join
    digests[flag] = Digest::MD5.hexdigest(text)
  end
  if digests.values.uniq.size != 1
    ok = false
    puts "poly-cold-test: FAIL (the object depends on the overflow mode; a function reaching an overflow-checked helper must stay in spinel_rt.h)"
    digests.each { |f, d| puts "  #{f.empty? ? '(none)' : f}: #{d}" }
  end

  # 2. writable statics reachable from the exported functions
  o = File.join(dir, "a.o")
  run(env, *cc, "-O0", "-w", "-c", "-ffunction-sections", "-fdata-sections", *inc, src, "-o", o)
  # The walk reads ELF relocation sections (readelf -rW, .rela.text.<function>). A Mach-O
  # object (macOS) has neither: its functions are atoms of one __text section. Check 2 is
  # skipped there and says so; Linux (CI and the gate on Linux) runs it.
  unless File.binread(o, 4) == "\x7fELF".b
    puts "poly-cold-test: check 1 passed; check 2 (writable statics) needs an ELF object and was skipped (#{File.binread(o, 4).unpack1('H*')})" if ok
    exit(ok ? 0 : 1)
  end
  roots = run(env, "nm", "--defined-only", o).lines.map(&:split).select { |f| f.size == 3 && f[1] == "T" }.map(&:last)
  graph = Hash.new { |h, k| h[k] = [] }
  cur = nil
  run(env, "readelf", "-rW", o).each_line do |l|
    if (m = l.match(/^Relocation section '\.rela\.text\.(?:unlikely\.)?([^']*)'/))
      cur = m[1]
    elsif l.start_with?("Relocation section")
      cur = nil
    elsif cur && (f = l.split).size >= 5 && f[0].match?(/\A[0-9a-f]{8,}\z/)
      graph[cur] << f[4].sub(/\A\.text\.(?:unlikely\.)?/, "")
    end
  end
  # .data.rel.ro is a constant table the loader relocates, not writable state
  writable = /\A\.(?:t?bss|tdata)\.|\A\.data\.(?!rel\.ro)/
  seen = {}
  reached = {}
  stack = roots.dup
  until stack.empty?
    f = stack.pop
    next if seen[f]
    seen[f] = true
    graph[f].each do |s|
      if s.match?(writable)
        reached[s] ||= f
      else
        base = s.sub(/\.(?:cold|constprop\.\d+|isra\.\d+|part\.\d+)\z/, "")
        stack << (graph.key?(s) ? s : base)
      end
    end
  end
  unless reached.empty?
    ok = false
    puts "poly-cold-test: FAIL (a writable static is reachable; the generated unit owns it, so declare it extern for SPINEL_EXT_HOST)"
    reached.each { |s, f| puts "  #{s} (first used by #{f})" }
  end
  puts "poly-cold-test: #{roots.size} exported functions, #{seen.size} reachable, writable statics reached: #{reached.size}" if ok
end
exit(ok ? 0 : 1)
