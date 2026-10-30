# A class's or module's own detect / collect_concat answers a call of it,
# written, sent or held, from outside and from its other class methods,
# though detect and collect_concat are find and flat_map under another
# name for an Enumerable.
class C
  def self.detect = :c_detect
  def self.collect_concat = :c_collect_concat
  def self.go = [detect, collect_concat, self.detect]
end
module M
  def self.detect = :m_detect
end
p C.detect
p C.collect_concat
p M.detect
p C.go
p C.send(:detect)
m = :detect
p C.public_send(m)
p [1, 2, 3].find { |x| x > 1 }
p [[1], [2]].flat_map { |x| x }
