# A Class value holding a reopened builtin (String, Array, Object) constructs
# it with new, like the constant spelling does.
class String
  def shout = upcase + "!"
end

class Array
  def hello = "hi"
end

class Object
  def tag = "obj"
end

class Foo
  def to_s = "foo"
end

def str_or_foo(n)
  m = String
  m = Foo if n == 2
  m.new
end
s = str_or_foo(1)
p s.class
s << "hey"
p s
p str_or_foo(2).to_s

def str_arg(n)
  m = String
  m = Foo if n == 2
  n == 1 ? m.new("abc") : m.new.to_s
end
p str_arg(1), str_arg(2)

def arr(n)
  m = Array
  m = String if n == 2
  n == 1 ? m.new(3) { |i| i * 10 } : m.new("x")
end
p arr(1), arr(2)

def obj(n)
  m = Object
  m = Foo if n == 2
  m.new
end
p obj(1).class, obj(2).to_s

def spl(n, *a)
  m = Array
  m = String if n == 2
  m.new(*a)
end
p spl(1, 2, :z), spl(2, "q")

p [String, Array, Object].map { |k| k.new.class }
p "x".shout, [1, 2].hello, 1.tag
