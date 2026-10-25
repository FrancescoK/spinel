# frozen_string_literal: true
require_relative 'numbers'

class NumbersIndex
  def initialize(n)
    @n = n
  end

  def to_int = @n
end
class NumbersPlain; end

[0, -7, 2**40, -(2**40), 1.9, -1.9, 1e15].each do |value|
  p CextNumbers.to_long(value)
end
p CextNumbers.next_long(41)
p CextNumbers.to_long(NumbersIndex.new(12))
p CextNumbers.double_int(NumbersIndex.new(-4))
p CextNumbers.double_int(-21)
[nil, true, false, "3", :three, [1], NumbersPlain.new, 2**64, -(2**64), 1e20, Float::NAN, Float::INFINITY].each do |value|
  CextNumbers.to_long(value)
rescue TypeError, RangeError, FloatDomainError => e
  p [e.class, e.message]
end
[2**40, -(2**40), 2.5e10, nil, "x"].each do |value|
  CextNumbers.double_int(value)
rescue TypeError, RangeError => e
  p [e.class, e.message]
end
