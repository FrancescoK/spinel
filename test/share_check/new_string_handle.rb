# A String no other name holds, handed on by the handle: the String plan's
# supply for it is that handle, not a wrap, wherever the C passes one. A
# value is "new" to the plan when it is made on the spot (a literal copy, a
# method's built String, a block's value) and is given to a consumer that
# keeps it; the C hands a consumer one handle there, which no other name can
# tell from a wrap of the bytes. Three ways the handle is made apart from the
# value's own text: the box face of a kept Array or Hash element makes it
# (the parentheses around the value only pass the box on, however many),
# the caller picks up the handle a method publishes (a built String, an
# exception's text override), and a block's value (`then`) is picked up too.
# A call that answers a frozen literal is the literal's own handle.
s = +"ab"

# a new String boxed into a kept Array or Hash, under parentheses
a = [((((s.upcase)))), 1]
a[0] << "!"
h = { k: ((s.downcase)), n: 1 }
h[:k] << "?"
p a[0], h[:k], s

# a method's built String, kept by a variable
def build(n)
  out = +""
  n.times { |i| out << i.to_s }
  out
end
r = build(4)
r << "z"
q = build(2)
p r, q

# an exception's text override: a new String, and a frozen literal
class Fresh < StandardError
  def message = +"new" + "!"
end
class Lit < StandardError
  def to_s = "frozen"
end
m = Fresh.new.message
m << "?"
l = Lit.new.to_s
p m, l, l.frozen?, l.equal?(Lit.new.to_s)

# a block's value, kept by a variable
b = s.then { |v| v + "f" }
b << "g"
p b

# a boxed receiver's to_s, over a user answer that is a new String
class A; def foo = +"a" + "b"; end
class B; def foo = 7; end
objs = [A.new, B.new]
x = objs[0].foo.to_s
y = x
y << "!"
p x

# an in-place change of a new String: the receiver is the bytes of a String
# no other name holds, and the answer is the one that is kept
def pick(v) = v + ""
def mk(v) = +"" + v
r1 = pick(s).upcase!
r1 << "c"
mk("q") << "!"
r2 = mk("w").concat("1").upcase!
p r1, r2, s
