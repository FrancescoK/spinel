# A top-level def or a class method named after a Hash method or an
# exception accessor leaves that builtin to a boxed Hash or exception.
def key(x) = [:top, x]
class Q
  def self.key(v) = [:q, v]
  def self.invert = :q_inv
  def self.cause = :q_cause
end
h = [{a: 1, b: 2}, 0][0]
p h.key(2)
p h.invert
p Q.key(3)
p Q.invert
e = begin; raise ArgumentError, "bad"; rescue => ex; ex; end
v = [e, nil][0]
p v.cause
p v.message
p Q.cause
