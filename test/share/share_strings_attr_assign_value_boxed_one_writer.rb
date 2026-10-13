# The value of an attribute assignment through a boxed receiver, where one
# user class has an explicit writer and the call's own link is a plain one
# (`x.a = s`, `bo&.b.a = s`): the right-hand side's String itself, whatever
# the writer returns, which changes with it through every name. A receiver
# that is nil or of another class raises NoMethodError before anything is
# stored. The value is kept in a variable, a container, a global and an
# instance variable, handed to a method, answered by one and frozen; the
# writer may keep a copy, change its parameter, come from a module or be
# inherited.
class K
  attr_reader :a
  def initialize = (@a = +"x")
  def a=(v)
    @a = v
    0
  end
end
class B
  def initialize(k) = (@k = k)
  def b = @k
end

o = K.new
s = +"s"
pick = ARGV.size

# a safe-navigation link before the plain writer link: nil raises at the
# writer, an object answers the right-hand side's String
[nil, B.new(o)].each do |bo|
  begin
    r = (bo&.b.a = s)
    r << "1"
    p [r, o.a, s, r.equal?(s)]
  rescue NoMethodError => e
    p e.message
  end
end
s << "2"
p [o.a, s]

# a boxed receiver: the object, nil or an Integer
q = [o, nil][pick]
t = +"t"
r = (q.a = t)
t << "1"
p [r, o.a, t]
r << "2"
p [r, o.a, t, o.a.equal?(t)]
[nil, 1].each do |bad|
  begin
    r = (bad.a = t)
  rescue NoMethodError => e
    p e.message
  end
end
p [r, o.a]

# kept in a container, a global, an instance variable; handed on and answered
u = +"u"
arr = [(q.a = u)]
arr[0] << "1"
$g = (q.a = u)
$g << "2"
class H
  def put(q, s) = (@r = (q.a = s))
  def r = @r
end
h = H.new
h.put(q, u)
u << "3"
def bump(x) = x << "4"
bump(q.a = u)
def set(q, s) = (q.a = s)
set(q, u) << "5"
p [arr, $g, h.r, o.a, u]

# chained assignments, then frozen through one name
v = +"v"
x = (q.a = v)
y = (q.a = x)
y << "!"
y.freeze
p [x, y, o.a, v, v.frozen?, o.a.frozen?, x.equal?(v)]

# a writer that keeps a copy, and one that changes its parameter
class D
  attr_reader :d
  def d=(v)
    @d = v.dup
    nil
  end
end
class C
  attr_reader :c
  def c=(v)
    v << "!"
    @c = v
  end
end
dd = [D.new, nil][pick]
w = +"w"
r = (dd.d = w)
r << "1"
p [r, dd.d, w]
cc = [C.new, nil][pick]
r = (cc.c = w)
r << "2"
p [r, cc.c, w]

# a writer from a module, and one a subclass inherits
module M
  def m=(v)
    @m = v
    0
  end
end
class E
  include M
  attr_reader :m
end
class F < E
end
[E.new, F.new].each do |e|
  z = +"z"
  r = ([e, nil][pick].m = z)
  r << "1"
  p [r, e.m, z]
end
