# A class that defines `+`, then (in a later reopening) aliases `+` to
# another method: a `+` on some other value, in another class's body or at
# the top level between the two, is not a call of that class's `+` (tzinfo's
# `Time.now.utc.year + 100` between activesupport's Date#+ and its
# `alias_method :+, :plus_with_duration`).
class Money
  attr_reader :cents
  def initialize(c) = @cents = c
  def +(o) = Money.new(cents + o.cents)
  def plus_twice(o) = Money.new(cents + o.cents * 2)
end

class Calendar
  LIMIT = Time.at(0).utc.year + 100
  def self.limit = LIMIT
end
TOTAL = 1 + 2

class Money
  alias_method :plus_without_twice, :+
  alias_method :+, :plus_twice
end

p Calendar.limit, TOTAL
p (Money.new(1) + Money.new(2)).cents, Money.new(1).plus_without_twice(Money.new(2)).cents
