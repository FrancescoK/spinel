# A reopening's alias of a method a required file defines takes that
# method, as the files run in that order: the require comes first.
require_relative "alias_lib"
m = Money.new(1)
class Money
  def plus_with_list(other) = other.is_a?(Array) ? plus_without_list(other[0]) : plus_without_list(other)
  alias_method :plus_without_list, :+
  alias_method :+, :plus_with_list
end
p (m + [3]).cents
p (m + 4).cents
