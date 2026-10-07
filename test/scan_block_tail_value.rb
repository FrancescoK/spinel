# String#scan with a block answers its receiver, at a method's tail too,
# where the method answered nil.
def f(s) = s.scan(/\d/) { print _1 }
p f("a1b2")
def g(s)
  s.scan(/(\w)(\d)/) { |a, b| print a, b }
end
p g("a1b2")
def h(s)
  @s = s
  @s.scan(/\d/) { print _1 }
end
p h("a3")
def k(s) = s.scan(/\d/)
p k("a1b2")
class S
  def scan(x)
    yield 1
    :mine
  end
end
def m(o) = o.scan(1) { }
p m(S.new)
