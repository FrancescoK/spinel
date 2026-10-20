# `self.class.public_send(:m)` (and send / __send__) in an instance method
# runs the inherited class method m on the instance's own class, so a
# class-level @ivar it reads is that class's, as `self.class.m` reads it.
class Base
  class << self
    def tagged = [name, @tag]
    def tagged_with(n, by: 1) = [name, @tag, n * by]
    def tag=(v)
      @tag = v
    end
  end

  def by_public_send = self.class.public_send(:tagged)
  def by_send = self.class.send(:tagged)
  def by_dunder_send = self.class.__send__(:tagged)
  def with_arg = self.class.public_send(:tagged_with, 4)
  def with_kw = self.class.send(:tagged_with, 5, by: 2)
  def by_string = self.class.public_send("tagged")
end

class A < Base; end
class B < A; end

Base.tag = :base
A.tag = :a
B.tag = :b

[Base, A, B].each do |k|
  o = k.new
  p [o.by_public_send, o.by_send, o.by_dunder_send]
  p [o.with_arg, o.with_kw, o.by_string]
end
p A.public_send(:tagged), B.send(:tagged_with, 3)

# written in a class that inherits the method itself: that class's own
# class-level ivar, unset here, and its subclass's
class Root
  @tag = :root
  def self.tagged = @tag
end

class Leaf < Root
  def read = self.class.public_send(:tagged)
  def read_direct = self.class.tagged
end

class Twig < Leaf
  @tag = :twig
end
p [Leaf.new.read, Leaf.new.read_direct, Twig.new.read, Twig.new.read_direct]
