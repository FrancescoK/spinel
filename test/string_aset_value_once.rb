# `s[i] = v` used as a value answers v, evaluated once. Its value form ran
# the store and then evaluated v again: a call with effects ran twice, and
# a v the store had read through a boxed dispatch (`x.to_str` on a String
# or a wrapper) came back boxed where the method answered a String, so
# the C did not compile. pines' SafeBuffer shim writes `@str[i] = ...` as
# a method's last expression.
class Buf
  def initialize(s) = @str = String.new(s)
  def to_str = @str
  def []=(a, b, c = nil)
    if c
      @str[a, b] = c.to_str
    else
      @str[a] = b.to_str
    end
  end
  def to_s = @str
end
b = Buf.new("hello")
b[0] = "J"
b[1, 2] = Buf.new("EL")
p b.to_s
p(b[4] = "O!")
$n = 0
def counted(s) = ($n += 1; s)
t = +"abc"
p(t[0] = counted("X"))
p t
p $n
