# A class includes a module defined inside it, which includes another module
# declaring attributes. The nested module is registered after the class that
# includes it, so the attributes it takes from its own include reached it
# only after the class had copied its surface, and `c.x` raised NoMethodError
# while a `def` from the same module worked.

class D
  module Slot
    attr_reader :x
    attr_writer :w
    attr_accessor :a
    def y = @x + 1
    def w_now = @w
    def label = "slot"
    alias_method :name, :label
  end
end

class C
  module B
    include D::Slot
  end

  module A
    include B
  end

  include A

  def initialize
    @x = 1
  end
end

c = C.new
p c.y
p c.x
c.w = 7
p c.w_now
c.a = "acc"
p c.a
p c.name
