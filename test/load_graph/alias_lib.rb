class Money
  attr_reader :cents
  def initialize(cents) = @cents = cents
  def +(other) = Money.new(@cents + other)
end
