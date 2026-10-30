# A class or module that extends Enumerable (or includes it in its
# singleton class) answers Enumerable's methods through its own #each:
# through its constant, in its class methods and body, and on
# self.class, where a class method of its own (or a superclass's below
# the extend) still comes first, and a subclass walks its own #each.

class C
  extend Enumerable
  def self.each
    yield 1
    yield 2
    yield 3
  end
end
p C.detect { |x| x > 1 }
p C.collect_concat { |x| [x, x] }
p C.map { |x| x * 2 }
p C.select(&:odd?)
p C.first
p C.first(2)
p C.to_a
p C.include?(2)
p C.each_slice(2).to_a
p C.sum
p C.sort.reverse
p C.min_by { |x| -x }
p C.inject(:+)
p C.is_a?(Enumerable)
p C.each_with_index.to_a
p C.lazy.map { |x| x * 10 }.first(2)

module Shop
  class Stock
    extend Enumerable
    def self.each(&b)
      return to_enum(:each) unless b
      { "apple" => 3, "pear" => 0, "fig" => 5 }.each { |k, v| yield k, v }
    end
    def self.count
      "own count"
    end
    def self.in_stock
      select { |_, v| v > 0 }.map(&:first)
    end
  end
  class Sub < Stock
    def self.each
      yield "kiwi", 1
      yield "lime", 2
    end
  end
end
p Shop::Stock.to_h
p Shop::Stock.count
p Shop::Stock.in_stock
p Shop::Sub.in_stock
p Shop::Sub.map { |k, v| k * v }
p Shop::Sub.count

class Nums
  class << self
    include Enumerable
    def each
      yield 4
      yield 1
      yield 3
    end
    def big
      select { |x| x > 2 }
    end
  end
  TOP = max
end
p Nums.big
p Nums.sort
p Nums::TOP
p Nums.minmax

module Colors
  extend Enumerable
  def self.each
    yield :red
    yield :green
  end
end
p Colors.map(&:to_s)
p Colors.to_a.size

module A
end
class A::Box
  extend Enumerable
  def self.each
    yield "x"
    yield "y"
  end
  def map
    "instance map"
  end
  def count
    self.class.count
  end
end
class A::Box
  def self.joined
    to_a.join("-")
  end
end
p A::Box.map.with_index { |s, i| "#{s}#{i}" }
p A::Box.joined
p A::Box.new.map
p A::Box.new.count
p A::Box.each_with_object([]) { |s, acc| acc << s.upcase }

class Pair
  def self.each
    yield 1, :a
    yield 2, :b
  end
end
Pair.extend(Enumerable)
p Pair.to_a
p Pair.map { |n, s| "#{s}#{n}" }

def map
  "top map"
end
class Q
  extend Enumerable
  def self.each
    yield 5
  end
  def self.run
    [map { |x| x + 1 }, self.map { |x| x + 2 }]
  end
end
p Q.run
p map
p [1].map { |x| x }

class Tag
  extend Enumerable
  def self.label = "tag"
end
puts Tag.label
