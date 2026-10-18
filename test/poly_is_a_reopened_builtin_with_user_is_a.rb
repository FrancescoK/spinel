# A boxed value's is_a?(Array) where the program reopens Array and some
# class defines its own is_a? goes through the dispatch, whose builtin arm
# asked only whether the value is a program object of the reopening: a real
# Array answered false, and the builtin flat_map pushed a block's Array
# whole instead of its elements (activesupport's descendants).
class Array
  def second = self[1]
end

class Hash
  def keys_size = keys.size
end

class Thing
  def is_a?(k) = k == Thing
end

def boxed(x) = x

vals = [boxed([1, 2]), boxed("s"), boxed(Thing.new), boxed([]), boxed({ a: 1 }), boxed(nil)]
p vals.map { |v| v.is_a?(Array) }
p vals.map { |v| v.kind_of?(Hash) }
p vals.map { |v| v.is_a?(Thing) }
p [1, 2].flat_map { |x| boxed(x == 1 ? [x, x] : "s") }
p [1, 2].flat_map { |x| boxed(x == 1 ? [] : [x]) }
