# `x.collect_concat.each { }` and `x.detect.each { }` call each on what
# x's own collect_concat or detect answers, though detect and
# collect_concat are find and flat_map under another name for an
# Enumerable, and an Array's call beside it still takes the builtin.
class C
  include Enumerable
  def each = yield(1)
  def collect_concat = [10, 20]
  def detect = [7]
end
p C.new.collect_concat.each { |x| x + 1 }
p C.new.detect.each { |x| x + 1 }
p [[1], [2]].collect_concat.each { |x| x }
p [1, 2].detect.each { |x| x > 1 }
