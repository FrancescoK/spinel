# `v.each_with_index.map { |x, i| ... }` on a poly value is folded into a loop
# that builds a typed result. When another class defines a method of the same
# name (a Struct synthesizes each_with_index, a user class defines map), the
# call is typed poly, but the fold still answered the unboxed array, so a
# method returning it failed to compile. Covers map, select, count, any? and
# to_h as a method's value.
Pair = Struct.new(:a, :b)

class Other
  def map(x, y) = [x, y]
  def select(x) = x
  def count(x) = x
  def any?(x) = x
  def to_h(x) = x
end

def pick(flag) = flag ? [5, 6, 7] : "ab"
def mapped(f) = pick(f).each_with_index.map { |x, i| x * i }
def selected(f) = pick(f).each_with_index.select { |x, i| i.odd? }
def counted(f) = pick(f).each_with_index.count { |x, i| x > 5 }
def any_at(f) = pick(f).each_with_index.any? { |x, i| i == 2 }
def hashed(f) = pick(f).each_with_index.to_h

p mapped(true)
p selected(true)
p counted(true)
p any_at(true)
p hashed(true)
p Pair.new(1, 2).to_a
o = Other.new
p o.map(1, 2)
p o.select(3)
