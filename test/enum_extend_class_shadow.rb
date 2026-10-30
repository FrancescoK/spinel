# A class that extends Enumerable keeps the class methods that come ahead
# of it: an accessor of its singleton class, define_singleton_method, a
# module extended after it (or before it in one `extend`), but not one
# extended before it, nor the body's own instance declarations; a constant
# names the class its namespace reaches; a body with rescue extends it too;
# and the class's constants are its own.

class Counter
  extend Enumerable
  class << self
    attr_accessor :count
  end
  def self.each
    yield 1
    yield 2
  end
end
Counter.count = 5
p Counter.count
p Counter.sum

module Firsts
  def first = "module first"
end
class Box
  extend Enumerable
  extend Firsts
  define_singleton_method(:min) { "own min" }
  def self.each
    yield 3
    yield 1
  end
end
p Box.first
p Box.min
p Box.max

class Item
  extend Enumerable
  def self.each
    yield 1
  end
end
module Admin
  class Item
    def self.map = "plain"
  end
  class Report
    def self.run = Item.map { |x| x }
  end
end
p Admin::Report.run
p Item.map { |x| x + 1 }

class Risky
  extend Enumerable
  def self.each
    yield :a
  end
  raise "boom" if false
rescue => e
  p e
end
p Risky.to_a
class Color
  extend Enumerable
  RED = 1
  GREEN = 2
  def self.each(&b) = constants.sort.map { |c| const_get(c) }.each(&b)
end
p Color.to_a
p Color.constants.sort


module Firsts
  def first = "module first"
  def min = "module min"
end
class Early
  extend Firsts
  extend Enumerable
  def self.each
    yield 3
    yield 1
  end
end
p Early.first
class Both
  extend Firsts, Enumerable
  def self.each
    yield 3
    yield 1
  end
end
p Both.first
class Rev
  extend Enumerable, Firsts
  def self.each
    yield 3
    yield 1
  end
end
p Rev.first
class Inst
  extend Enumerable
  attr_accessor :count
  alias_method :total, :count
  define_method(:sum) { 0 }
  def self.each
    yield 3
    yield 1
  end
end
p Inst.count
p Inst.sum
o = Inst.new
o.count = 7
p o.count
p o.sum
