# `super` from a method a module prepended into a builtin class gives it
# reaches the builtin's own method of that name (activesupport's
# RangeWithFormat, CompareWithRange, BigDecimalWithDefaultFormat).
module RangeFmt
  def to_s(format = :default) = format == :db ? "BETWEEN #{first} AND #{last}" : super()
end
module RangeCmp
  def include?(v) = v.is_a?(Range) ? (cover?(v.first) && cover?(v.last)) : super
end
class Range
  prepend RangeFmt
  prepend RangeCmp
end
p (1..3).to_s, (1..3).to_s(:db)
p (1..5).include?(2..3), (1..5).include?(9), (1..5).include?(3)

module IntFmt
  def to_s(format = nil) = format == :delimited ? "d#{super()}" : super()
end
class Integer; prepend IntFmt; end
p 12.to_s, 12.to_s(:delimited)

module FloatFmt
  def to_s(*args) = args.empty? ? super : "f"
end
class Float; prepend FloatFmt; end
p 1.5.to_s, 1.5.to_s(:x)

module Shout
  def upcase(*args) = "<" + super + ">"
end
class String; prepend Shout; end
p "ab".upcase

module FirstTagged
  def first(n = nil) = n ? super(n) : [:f, super()]
end
class Array; prepend FirstTagged; end
p [1, 2, 3].first, [1, 2, 3].first(2)

module Sized
  def size = super * 10
end
class Hash; prepend Sized; end
p({a: 1, b: 2}.size)
