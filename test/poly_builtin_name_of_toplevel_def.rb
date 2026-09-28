# A top-level def is a private method of Object: a builtin method of the
# same name called with an explicit boxed receiver is still the builtin
# (`def uniq(o) = o.uniq`), and the def returns the builtin's value.
def t; r = yield; p r; end
def uniq(o) = o.uniq
def pop(o) = o.dup.pop
def shift(o) = o.dup.shift
def compact(o) = o.compact
def flatten(o) = o.flatten
def keys(o) = o.keys
def to_a(o) = o.to_a
def clear(o) = o.dup.clear
def delete_at(o) = o.dup.delete_at(0)
def insert(o) = o.dup.insert(0, 9)
def message(o) = o.message
[[1, 1, nil], [3, [4]], { a: 1 }].each do |o|
  t { uniq(o) }
  t { o.is_a?(Array) ? pop(o) : :h }
  t { o.is_a?(Array) ? shift(o) : :h }
  t { compact(o) }
  t { o.is_a?(Array) ? flatten(o) : :h }
  t { o.is_a?(Hash) ? keys(o) : :a }
  t { to_a(o) }
  t { clear(o) }
  t { o.is_a?(Array) ? delete_at(o) : :h }
  t { o.is_a?(Array) ? insert(o) : :h }
end
[RuntimeError.new("m"), ArgumentError.new("n")].each { |e| t { message(e) } }

def size(o) = o.size
def reverse(o) = o.reverse
p size([1, 1]), size("abc")
p reverse([1, 2]), reverse("ab")
p pop([1, 2]), pop([3, "x"])
