# A method that answers its parameter answers a new String for a new
# argument only while nothing else holds the parameter. One that also
# stores it (`$g = x`, `@k = x`) answers the String the other name keeps,
# so a caller that changes the answer changes that name's too: through a
# call in a method's tail, through a conditional arm, and through the
# to_s a boxed value dispatches to.
$g = nil
def gkeep(x)
  $g = x
  x
end

def w = gkeep(+"n")

r = w
r << "!"
p r, $g, r.equal?($g)

class K
  def keep(x)
    @k = x
    x
  end

  def k = @k
end

def wk(o) = o.keep(+"n")

o = K.new
r = wk(o)
r << "!"
p r, o.k, r.equal?(o.k)

def wc(f) = f ? gkeep(+"a") : +"b"

q = wc(true)
q << "?"
p q, $g

$k = nil
def keep(x)
  $k = x
  x
end

class E1
  def to_s
    s = +"e1"
    $k = s
    s
  end
end

class E2
  def to_s = keep(+"e2")
end

def conv(s) = s.to_s

str = +"str"
[str, E1.new, E2.new].each do |e|
  t = conv(e)
  t << "!"
  p [t, $k]
end
p str
