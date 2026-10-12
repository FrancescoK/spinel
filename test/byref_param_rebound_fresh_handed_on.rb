# A String parameter the method rebinds to a fresh String before handing it
# on to a method that mutates it is the method's own String: the caller's
# stays as it was, so nothing needs to be lent. That holds when the String
# is handed to a plain call, to `super` with arguments or a bare `super`
# into an included module, or to a spliced yielding method whose block
# appends. Lent anyway, the rebind put the parameter on the shared handle,
# and a caller passing its own parameter on took it too, so that caller's
# `text = ident(text)` was refused as a mutated parameter.
def grow(t) = t << "!"
def ident(t) = t

def normalize(s)
  s = s.dup
  grow(s)
  s
end
def outer(text)
  text = normalize(text)
  text = ident(text)
  text
end
x = +"a"
p outer(x), x

module Grow
  def f(s) = s << "!"
  def g(s) = s << "?"
end
class Child
  include Grow
  def ident(t) = t
  def f(s)
    s = s.dup
    super(s)
    s
  end
  def g(s)
    s = s.dup
    super
    s
  end
  def outer_f(text)
    text = f(text)
    text = ident(text)
    text
  end
  def outer_g(text)
    text = g(text)
    text = ident(text)
    text
  end
end
x = +"b"
c = Child.new
p c.outer_f(x), c.outer_g(x), x

def each_grow(t)
  yield t
end
def spliced(s)
  s = s.dup
  each_grow(s) { |u| u << "#" }
  s
end
def outer_spliced(text)
  text = spliced(text)
  text = ident(text)
  text
end
x = +"c"
p outer_spliced(x), x

# still lent where the mutation reaches the caller's String
def ahead(io)
  io << "!"
  io = String.new("z")
  io << "!"
  io
end
s = +""
p ahead(s), s
