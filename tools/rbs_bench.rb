# What an RBS signature buys on one hot path (docs/inline-rbs.md).
#
#   ruby tools/rbs_bench.rb [--runs R] [--n N] [--parity-n N]
#
# benchmark/bm_rbs_items.rb loops over `bags[i & 63].items.size`, where
# `Bag#items` returns `@items || EMPTY`: some bags hold no array, so without a
# signature `items` is a boxed value and every `.size` is dispatched at run
# time. Its one inline annotation, `#: -> Array[Integer]`, says otherwise.
# benchmark/bm_rbs_items_control.rb is the same loop over a method inference
# already types precisely, annotated the same way.
#
# The same source is built four ways, by the same spinel, C compiler and -O:
#
#   none      --no-inline-rbs: the annotation is a comment
#   inline    the inline annotation (the default)
#   rbs       --no-inline-rbs --rbs benchmark/sig/bm_rbs_items: the same
#             signature from a .rbs file
#   control   the control program, annotated
#
# For each it reports how the hot `.size` is called in the generated C
# (sp_poly_size: a dispatch on a boxed value; sp_IntArray_length: the direct
# call), the executable's size and its .text, and the wall time of R runs at
# N iterations, the legs interleaved so that a change in machine load falls
# on all of them alike (median, min, max). It checks that the inline and the
# --rbs C are identical and that the control's C is the same with and without
# its annotation; that every leg's stdout, stderr and exit status equal
# CRuby's at --parity-n iterations; and that every leg prints the same thing
# at N.
#
# The numbers describe this loop on this machine. They say what one
# signature does to one call site, not how much faster a program gets.

require "tmpdir"
require "rbconfig"
require "open3"

ROOT = File.expand_path("..", __dir__)
SPINEL = File.join(ROOT, "spinel")
BENCH = File.join(ROOT, "benchmark")
PROG = File.join(BENCH, "bm_rbs_items.rb")
CONTROL = File.join(BENCH, "bm_rbs_items_control.rb")
SIG = File.join(BENCH, "sig", "bm_rbs_items")

def option(name, default)
  i = ARGV.index(name)
  i ? Integer(ARGV[i + 1]) : default
end
runs = option("--runs", 11)
n = option("--n", 200_000_000)
parity_n = option("--parity-n", 3_000_000)

LEGS = [
  [:none, PROG, ["--no-inline-rbs"]],
  [:inline, PROG, []],
  [:rbs, PROG, ["--no-inline-rbs", "--rbs", SIG]],
  [:control, CONTROL, []],
].freeze

def run!(*cmd)
  out, err, st = Open3.capture3(*cmd)
  abort "rbs_bench: #{cmd.join(' ')} failed:\n#{err}" unless st.success?
  out
end

# the .text size, where binutils' size(1) is there to read it
def text_size(bin)
  out, st = Open3.capture2e("size", "-A", bin)
  return nil unless st.success?
  line = out.lines.find { |l| l.start_with?(".text ") }
  line && Integer(line.split[1])
rescue Errno::ENOENT
  nil
end

def dispatch(cfile)
  c = File.read(cfile)
  %w[sp_poly_size sp_IntArray_length].select { |f| c.include?("#{f}(") }.join(" + ")
end

def median(xs)
  s = xs.sort
  s.size.odd? ? s[s.size / 2] : (s[s.size / 2 - 1] + s[s.size / 2]) / 2.0
end

rows = {}
Dir.mktmpdir("spinel-rbs-bench") do |dir|
  LEGS.each do |leg, prog, flags|
    cfile = File.join(dir, "#{leg}.c")
    bin = File.join(dir, leg.to_s)
    run!(SPINEL, prog, *flags, "-c", "--no-line-map", "-o", cfile)
    run!(SPINEL, prog, *flags, "-O", "2", "-o", bin)
    rows[leg] = { prog: prog, cfile: cfile, bin: bin, dispatch: dispatch(cfile),
                  size: File.size(bin), text: text_size(bin), times: [] }
  end
  same = ->(a, b) { File.binread(a) == File.binread(b) }
  inline_is_rbs = same.(rows[:inline][:cfile], rows[:rbs][:cfile])
  ctl_plain = File.join(dir, "control_plain.c")
  run!(SPINEL, CONTROL, "--no-inline-rbs", "-c", "--no-line-map", "-o", ctl_plain)
  control_unchanged = same.(rows[:control][:cfile], ctl_plain)

  # CRuby parity: stdout, stderr and exit status, at a size CRuby runs quickly
  ruby = {}
  [PROG, CONTROL].each do |prog|
    ruby[prog] = Open3.capture3(RbConfig.ruby, "--enable-frozen-string-literal", prog, parity_n.to_s)
  end
  parity = rows.map do |leg, r|
    out, err, st = Open3.capture3(r[:bin], parity_n.to_s)
    want_out, want_err, want_st = ruby[r[:prog]]
    [leg, out == want_out && err == want_err && st.exitstatus == want_st.exitstatus]
  end.to_h

  outputs = Hash.new { |h, k| h[k] = [] }
  runs.times do
    rows.each do |leg, r|
      t = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      out, st = Open3.capture2(r[:bin], n.to_s)
      r[:times] << Process.clock_gettime(Process::CLOCK_MONOTONIC) - t
      abort "rbs_bench: #{leg} exited #{st.exitstatus} at N=#{n}" unless st.success?
      outputs[r[:prog]] << out
    end
  end
  consistent = outputs.values.all? { |outs| outs.uniq.size == 1 }

  load = File.read("/proc/loadavg").split.first(3).join(" ") rescue "?"
  puts "rbs_bench: #{runs} interleaved runs per leg at N=#{n}; CRuby parity at N=#{parity_n}; " \
       "load average #{load}"
  puts format("%-8s %-20s %12s %10s %9s %9s %9s %8s %7s", "leg", "hot .size call", "binary",
              ".text", "median s", "min s", "max s", "vs none", "CRuby")
  base = median(rows[:none][:times])
  rows.each do |leg, r|
    m = median(r[:times])
    puts format("%-8s %-20s %12d %10s %9.3f %9.3f %9.3f %7.2fx %7s", leg, r[:dispatch], r[:size],
                r[:text] ? r[:text].to_s : "-", m, r[:times].min, r[:times].max, base / m,
                parity[leg] ? "same" : "DIFFERS")
  end
  puts "inline C #{inline_is_rbs ? '==' : '!='} --rbs C; " \
       "control C #{control_unchanged ? 'unchanged' : 'CHANGED'} by its annotation; " \
       "outputs at N #{consistent ? 'consistent' : 'INCONSISTENT'}"
  exit(inline_is_rbs && control_unchanged && consistent && parity.values.all? ? 0 : 1)
end
