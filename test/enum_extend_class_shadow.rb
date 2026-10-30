# A class that extends Enumerable keeps the class methods that come ahead
# of it: an accessor of its singleton class, define_singleton_method, a
# module extended after it (or before it in one `extend`, or after an
# earlier body extended Enumerable, or one that module includes), a
# singleton prepend, its own is_a?, but not a module extended before it,
# nor the body's own instance declarations; a constant names the class its
# namespace reaches; a body with rescue extends it too; the class's
# constants are its own; and a class or class method of the program
# named like the twin or its accessor is left alone.

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

module Custom
  def first = :custom
end
class Pre
  singleton_class.prepend Custom
  extend Enumerable
  def self.each
    yield 1
  end
end
p Pre.first
class Again
  extend Enumerable
  def self.each
    yield 1
  end
end
class Again
  extend Custom
  extend Enumerable
end
p Again.first
class Liar
  extend Enumerable
  def self.each
    yield 1
  end
  def self.is_a?(m) = false
end
p Liar.is_a?(Enumerable)
p Liar.to_a

module WrappedFirsts
  def first = :from_firsts
end
module Wrapper
  include WrappedFirsts
end
class Wrapped
  extend Enumerable
  extend Wrapper
  def self.each
    yield 1
  end
end
p Wrapped.first
p Wrapped.to_a
class Named
  class SpinelEnumerableSelf
    def each = "the program's"
  end
  extend Enumerable
  def self.each
    yield 4
    yield 5
  end
end
p Named.map { |x| x * 2 }
p Named::SpinelEnumerableSelf.new.each

class Acc
  extend Enumerable
  def self.each
    yield 6
    yield 7
  end
  def self.__spinel_enum_self = "the program's accessor"
end
p Acc.map { |x| x + 1 }
p Acc.__spinel_enum_self
