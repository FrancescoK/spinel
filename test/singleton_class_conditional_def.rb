# A def inside if/unless/else inside `class << self` is a class method, as
# `def self.m` in the same place is. Loofah defines its entry points this way.
module L
  class << self
    if ENV["SPINEL_TEST_NEVER_SET"] == "1"
      def h5 = "yes"
    else
      def h5 = "no"
    end
    unless false
      def u = :unless
    end
    def plain = h5 + "!"
  end
end

class K
  class << self
    if 1 > 0
      def build(x) = new(x)
    end
  end
  def initialize(x) = @x = x
  attr_reader :x
end

p L.h5, L.u, L.plain
p K.build(3).x
