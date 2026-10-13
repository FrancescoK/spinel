# A method whose tail is a builtin over a call that publishes its handle
# (`(+json_value(json)).force_encoding("UTF-8")`, a Rails application's
# MessageVerifier.verified in #8328) publishes the handle too, whatever
# order the two methods are defined in: the callee's answer is decided
# where the tail asks it, not after the caller.
def outer(s)
  return "" if s == ""
  (+inner(s)).force_encoding("UTF-8")
end

def inner(j)
  return j if j.length < 3
  +"long"
end

s = +"ab"
t = outer(s)
t << "!"
u = outer(+"abcd")
w = u
w << "?"
p s, u

def a1(s) = b1(s).itself
def b1(x) = x
r = +"q"
a1(r) << "1"
p r

# a chain defined innermost last, and a nil beside it
def m1(s, f)
  return nil if f
  (+m2(s)).force_encoding("UTF-8")
end
def m2(s) = (+m3(s)).force_encoding("UTF-8")
def m3(s) = s
x = +"x"
m1(x, false) << "y"
p x, m1(x, true), m1(x, false)&.upcase

# through super, a boxed receiver's dispatch and String()
class P
  def label(s) = (+base(s)).force_encoding("UTF-8")
  def base(s) = s
end
class Q < P
  def label(s) = super
end
z = +"z"
Q.new.label(z) << "!"
P.new.label(z) << "?"
p z

class A
  def initialize(n) = @n = n
  def name = (+nm).force_encoding("UTF-8")
  def nm = @n
  def to_str = (+nm).force_encoding("UTF-8")
end
class B
  def initialize(m) = @m = m
  def name = (+nm).force_encoding("UTF-8")
  def nm = @m
end
c = +"c"
xs = [A.new(c), B.new(+"b")]
xs[0].name << "!"
String([A.new(c), 1][0]) << "?"
p c, xs[1].name

# an exception's message and a subclass's reader override, each over a
# method defined after it
class MyErr < StandardError
  def initialize(s) = (@s = s; super(s))
  def message = (+txt).force_encoding("UTF-8")
  def txt = @s
end
bx = +"boom"
begin
  raise MyErr.new(bx)
rescue => err
  em = err.message
  em << "!"
  p bx, err.message
end

class R
  attr_reader :name
  def initialize(n) = @name = n
end
class S < R
  def name = (+inner).force_encoding("UTF-8")
  def inner = @name
end
rx = +"r"
[R.new(rx), S.new(rx)].each { |o| o.name << "!" }
p rx
