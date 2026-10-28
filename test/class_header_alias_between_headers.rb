# A name a header made a class, then written to hold another class, is an
# alias at a later header: that header reopens the class the name holds
# there.
class Foo
  def foo = 1
end
class A
  def a = 2
end
A = Foo
class A
  def extra = 3
end
p Foo.new.respond_to?(:extra)
p A.equal?(Foo)
