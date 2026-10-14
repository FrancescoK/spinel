# A declaration told to a class's singleton class, as a statement of the
# program's or a class or module body, declares on the class as a
# `class << X` body does: attr_*, define_method, alias_method, their send
# forms and a class_eval block.

class Foo
  singleton_class.attr_accessor :a
  self.singleton_class.send(:define_method, :m) { 42 }
  singleton_class.class_eval do
    attr_reader :r
    def h = :h
  end
  @r = :rv
end
Foo.singleton_class.class_eval { attr_accessor :b }
Foo.singleton_class.send(:define_method, :n) { |x| x * 2 }
Foo.singleton_class.alias_method :h2, :h
Foo.singleton_class.public_send(:attr_writer, :w)
Foo.a = 1
Foo.b = 2
Foo.w = 3
p Foo.a, Foo.b, Foo.m, Foo.n(5), Foo.h, Foo.h2, Foo.r
p Foo.singleton_methods.sort
module Mod
  singleton_class.send(:attr_accessor, :conf)
end
Mod.conf = :c
p Mod.conf
