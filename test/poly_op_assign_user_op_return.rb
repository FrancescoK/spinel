# `@x += v` on a slot that holds an Integer or an object of a class with
# its own `+`: the operator's result is boxed as that method returns it.
# A `+` answering a mix of kinds, an Integer, a String, an object of
# another class or nil all came out cast to an object pointer, which did
# not compile or carried the wrong class.
class Mixed
  def initialize(s); @s = s; end
  def +(o); o == "" ? "empty" : Mixed.new(@s + o); end
  def s; @s; end
end

class Count
  def +(o); o.length; end
end

class Label
  def +(o); "label:#{o}"; end
end

class Wrap
  def initialize(v); @v = v; end
  def v; @v; end
end

class Boxer
  def +(o); Wrap.new(o); end
end

class Maybe
  def +(o); o == "none" ? nil : self; end
end

class Acc
  def initialize(x); @n = x; end
  def add(k); @n += k; @n; end
end

p Acc.new(1).add(2)
p Acc.new("a").add("b")
p Acc.new(Mixed.new("x")).add("y").s
p Acc.new(Mixed.new("x")).add("")
p Acc.new(Count.new).add("abcd")
p Acc.new(Label.new).add("q")
r = Acc.new(Boxer.new).add("w")
p [r.class, r.v]
p Acc.new(Maybe.new).add("none")
p Acc.new(Maybe.new).add("some").class
