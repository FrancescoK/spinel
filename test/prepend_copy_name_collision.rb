# A method the program names exactly as a prepend's hidden copy (`__prep <n>
# <name>`) is its own: the compiler picks a copy name no program method has,
# and the name queries, send, method lists, __method__ and original_name
# answer the program's method, never the copy.
module M
  def foo = "M+" + super
end

# a real prepend over the same class, whose program already names the first
# copy indices (a define_method and an alias)
class C
  def foo = "C"
  define_method(:"__prep 0 foo") { "own" }
  alias_method :"__prep 1 foo", :foo
  prepend M
end

class D
  define_method(:"__prep 0 bar") { __method__ }
end

c = C.new
p c.foo
p C.instance_methods(false).sort
p [c.respond_to?(:"__prep 0 foo"), C.method_defined?(:"__prep 0 foo"), C.public_method_defined?(:"__prep 0 foo")]
p [c.send(:"__prep 0 foo"), c.public_send(:"__prep 0 foo"), c.__send__(:"__prep 0 foo"), c.method(:"__prep 0 foo").call]
p c.send(:"__prep 1 foo")
p c.method(:"__prep 1 foo").original_name
# the hidden copy's own index is not a method
p c.respond_to?(:"__prep 2 foo")
p((c.send(:"__prep 2 foo") rescue $!.class))
p((c.public_send(:"__prep 2 foo") rescue $!.class))
p C.method_defined?(:"__prep 2 foo")
d = D.new
p D.instance_methods(false)
p d.send(:"__prep 0 bar")
p d.method(:"__prep 0 bar").original_name

# a later top-level reopening that prepends: the call before and after it
class K
  def foo = "K"
end
class K
  define_method(:"__prep 0 foo") { "own" }
end
module L
  def foo = "L+" + super
end
k = K.new
p k.foo
p k.send(:"__prep 0 foo")
class K
  prepend L
end
p k.foo
p k.send(:"__prep 0 foo")
p K.instance_methods(false).sort

# the singleton side
module SM
  def bar = "SM+" + super
end
class S
  def self.bar = "S"
  define_singleton_method(:"__prep 0 bar") { "sown" }
  class << self
    prepend SM
  end
end
p S.bar
p S.respond_to?(:"__prep 0 bar")
p [S.send(:"__prep 0 bar"), S.public_send(:"__prep 0 bar"), S.method(:"__prep 0 bar").call]
p S.respond_to?(:"__prep 1 bar")
