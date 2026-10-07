# Flag-only. An Enumerable method of a class whose each yields a String it
# holds answers that String itself, as CRuby's do: first, find and take
# (served by a generator), to_a, min, select, sort_by, map, max and
# each_with_index (served by the eager element Array), a lazy enumerator's
# first and to_enum's next.

class One
  include Enumerable
  def initialize(s); @s = s; end
  def each; yield @s; end
end

class Bag
  include Enumerable
  def initialize; @items = []; end
  def add(s); @items << s; self; end
  def each
    @items.each { |i| yield i }
    self
  end
end

def first_of_one
  s = +"ab"
  x = One.new(s).first
  x << "c"
  p s
end

def find_and_take
  s = +"ab"
  o = One.new(s)
  o.find { |e| e.size == 2 } << "d"
  o.take(1)[0] << "e"
  o.first(1)[0] << "f"
  p s
end

def eager_methods
  s = +"ab"
  o = One.new(s)
  o.to_a[0] << "g"
  o.min << "h"
  o.select { |e| e }[0] << "i"
  o.sort_by { |e| e.size }[0] << "j"
  o.map { |e| e }[0] << "k"
  p s
end

def through_an_array
  a = +"ab"
  b = +"xy"
  bag = Bag.new.add(a).add(b)
  bag.first << "l"
  bag.max << "m"
  bag.each_with_index { |e, i| e << i.to_s }
  p a
  p b
end

def lazy_and_next
  s = +"ab"
  o = One.new(s)
  o.lazy.first << "n"
  o.to_enum(:each).next << "o"
  p s
end

first_of_one
find_and_take
eager_methods
through_an_array
lazy_and_next
