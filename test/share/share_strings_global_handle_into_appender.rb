# --share-strings: a global or a class variable that holds a shared
# String's handle hands that handle to a method's parameter that appends to
# it, so the append reaches the caller's String and every other name of it;
# the call was refused as handing the method a copy. A reassignment of the
# global inside the method does not move the parameter, as in CRuby.
def app(s)
  s << "x"
  nil
end
def app_kw(s:)
  s << "k"
  nil
end
def two(a, b)
  a << "1"
  b << "2"
  nil
end
def rebind(s)
  $g = +"other"
  s << "r"
  nil
end
def attempt(s)
  s << "x"
  "mutated"
rescue FrozenError
  "FrozenError"
end
s = +"gl"
$g = s
app($g)
app_kw(s: $g)
p s, $g.equal?(s)
$h = s
two($g, $h)
p s
rebind($g)
p s, $g
t = +"t"
$g = nil
$g = t if ARGV.size == 0
puts attempt($g)
p t
class K
  @@v = nil
  def self.setup(s) = (@@v = s)
  def self.show = @@v
  def self.direct = app2(@@v)
  def self.app2(s)
    s << "c"
    nil
  end
end
c = +"cv"
K.setup(c)
K.direct
p c, K.show.equal?(c)
