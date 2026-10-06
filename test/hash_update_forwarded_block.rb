# Hash#update with a forwarded `&block`, in a method spliced in where it is
# called: with no block at the call it merges plainly, and with one the
# block resolves each collision. The forwarded block went to the
# collision path as written, so with none a colliding key took nil, and
# with one its parameters were never bound. pines' HashWithIndifferentAccess
# shim updates this way.
class H
  def initialize = @hash = {}
  def to_hash_raw = @hash
  def []=(k, v)
    @hash[k] = v
  end
  def regular_update(other, &block)
    @hash.update(other.to_hash_raw, &block)
    self
  end
  def inspect = @hash.inspect
end
a = H.new; a["x"] = 1
b = H.new; b["x"] = 2; b["y"] = 3
a.regular_update(b)
p a
c = H.new; c["x"] = 10
a.regular_update(c) { |k, o, n| o + n }
p a
