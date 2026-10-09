# Annotations on methods a block defines: in a class_eval block, and a
# `def self.` in a Module.new body. Each is applied to the right owner, or
# reported at its line; none is dropped without a word.
class Foo; end

Foo.class_eval do
  #: (untyped) -> untyped
  def m(x) = x
end

Mod = Module.new do
  #: (untyped) -> untyped
  def self.q(x) = x
end

p Foo.new.m(1)
p Mod.q(2)
