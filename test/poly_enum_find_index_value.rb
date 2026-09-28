# Enumerable#find_index(value) on a boxed Range, Hash, Enumerator or user
# Enumerable: the position of the first element equal to the value.
class Bag
  include Enumerable
  def each
    yield 7
    yield 8
  end
end

def fi(o, v) = o.find_index(v)
p fi([2, 1], 2)
p fi(1..3, 2)
p fi(1..3, 9)
p fi({ a: 1, b: 2 }, [:b, 2])
p fi({ a: 1 }, :a)
p fi([5, 6].each, 6)
p fi(Bag.new, 8)
p fi(Bag.new, 1)
begin
  fi(5, 1)
rescue NoMethodError => e
  p e.class
end
