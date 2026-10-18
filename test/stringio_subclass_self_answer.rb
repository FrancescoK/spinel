# A StringIO method that answers self (<<, flush), called on a subclass
# instance, answers the subclass object: as a method's tail value, a local's
# value, a chain's receiver and through super.
require "stringio"

class Plain < StringIO
  def hi = "hi"
  def add(x) = (self << x)
  def add2(x)
    self << x
  end
  def twice(x) = (self << x << x)
  def flushed = flush
  def again(x)
    flush
    self << x
  end
end

c = Plain.new
p c.add("a").string
p c.add2("b").class
p c.twice("c").hi
p c.flushed.class
p c.again("d").string
d = (c << "e")
p d.hi, d.string
f = c.flush
p f.hi
c << "f" << "g"
p c.string
p((c << "h").hi)
x = c.add("i").add("j")
p x.string

class Over < StringIO
  def <<(x)
    super
  end
  def flush
    super
  end
  def put(x) = (self << x)
end

o = Over.new
p o.put("k").class
p((o << "l").class)
p o.flush.class
p o.string

class Wrap < StringIO
  def <<(x) = super("[" + x + "]")
end
w = Wrap.new
p((w << "m" << "n").class)
p w.string
