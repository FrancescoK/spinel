# A boxed receiver holding an instance whose own collect_concat or detect
# takes an argument answers a call of it by that method, though detect and
# collect_concat are find and flat_map under another name for an
# Enumerable, and an Array beside it still takes the builtin.
class CC
  include Enumerable
  def each = yield(1)
  def collect_concat(n) = [:own, n]
  def detect(n) = [:own_detect, n]
end
class Plain
  def collect_concat(n) = [:plain, n]
end
xs = [CC.new, [[1], [2]]]
p xs[0].collect_concat(123)
p xs[0].detect(5)
p xs[1].collect_concat { |x| x }
ys = [Plain.new, [[3]]]
p ys[0].collect_concat(7)
m = :collect_concat
p xs[0].public_send(m, 9)
