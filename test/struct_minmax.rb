# minmax on a Struct answers [min, max] of its values, as Enumerable#minmax
# does; a class that mixes Enumerable in keeps its answer, and one with a
# bare #each still has no minmax.
S = Struct.new(:a, :b, :c)
s = S.new(3, 1, 2)
p s.minmax, s.min, s.max, S.new("b", "a", "c").minmax
class Bag
  include Enumerable
  def each
    yield 3
    yield 1
  end
end
p Bag.new.minmax
class Bare
  def each
    yield 1
  end
end
begin
  Bare.new.minmax
rescue NoMethodError => e
  puts e.message
end
