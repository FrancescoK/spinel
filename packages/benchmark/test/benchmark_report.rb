# Benchmark.benchmark with an empty format prints each label and no times,
# and answers the Tms list it measured; a block's extra results are the
# totals printed after the list.
require "benchmark"

list = Benchmark.benchmark("", 8, "", ">total:") do |x|
  t1 = x.report("first") { 10.times { |i| i } }
  t2 = x.report("second") { [3, 1, 2].sort }
  [t1 + t2]
end
puts
p list.size, list.map(&:label), list.map(&:class).uniq
