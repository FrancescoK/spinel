# A (...) forwarder finds the method it reaches when the forwarder is a
# `private def` and a same-named class exists in another namespace, and when
# the superclass is reachable only through a module the enclosing module
# includes.

class Thing
  def initialize(k:) = (@v = [:top, k])
  def v = @v
end

module NS
  class Thing
    def initialize(a, b = 6) = (@v = [:ns, a, b])
    def v = @v
  end

  class Maker
    def make(...) = Thing.new(...)
    def via(x) = mk(x)
    def via2(x, y) = mk(x, y)

    private def mk(...) = Thing.new(...)
  end

  class Parent
    private def step(x, y = 2) = [:parent, x, y]
  end

  class Child < Parent
    def go(*a) = step(*a)

    private def step(...) = super(...)
  end
end

p NS::Maker.new.make(1).v
p NS::Maker.new.via(2).v
p NS::Maker.new.via2(3, 4).v
p NS::Child.new.go(5)
p NS::Child.new.go(5, 6)

module Lib
  class Base
    def run(x, y = 1) = [:lib, x, y]
  end
end

module N
  include Lib

  class C < Base
    def run(...) = super(...)
  end
end

p N::C.new.run(4)
p N::C.new.run(4, 5)
