# Benchmark::Tms arithmetic and formatting on fixed values, and the shapes
# measure / realtime / ms answer (their times vary, so only their kinds are
# printed).
require "benchmark"

a = Benchmark::Tms.new(1.5, 0.25, 0.0, 0.0, 2.0, "alpha")
b = Benchmark::Tms.new(0.5, 0.25, 0.0, 0.0, 1.0, "beta")
p a.utime, a.stime, a.total, a.real, a.label
puts a.format
puts a.format("%n: %u + %y = %t (%r)\n")
puts a.to_s
p a.to_a
p a.to_h
p (a + b).to_a
p (a - b).to_a
p (a * 2).to_a
p (a / 2).to_a
p Benchmark::CAPTION
p Benchmark::FORMAT

t = Benchmark.measure("m") { 100.times { |i| i } }
p t.class, t.label, t.real >= 0.0, t.total >= 0.0
p Benchmark.realtime { 100.times { |i| i } } >= 0.0
p Benchmark.ms { 100.times { |i| i } } >= 0.0
