# A class that includes a builtin module, and a reopening of that module
# with `module`, still compile. Only `class Comparable` is an error.
module Comparable
  def at_least?(other) = self >= other
end

class Version
  include Comparable
  attr_reader :n
  def initialize(n) = @n = n
  def <=>(other) = n <=> other.n
end

puts Version.new(2) < Version.new(5)
puts Version.new(5).at_least?(Version.new(2))
puts Comparable.class
