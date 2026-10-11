# String#freeze answers its receiver, frozen, through every route that hands
# a shared String on: freeze changes that String in place, so every name of it
# reads it frozen, and the answer is the same object (equal? to each name).
class Box
  attr_accessor :a
  def initialize = (@a = +"init")
end

class Keep
  def initialize(s) = (@s = s)
  def go
    @r = @s.freeze
    [@s.frozen?, @r.equal?(@s)]
  end
end

class Setter
  def initialize = (@a = +"x")
  def set(s) = (@a = s).freeze
  def a = @a
end

class Writer
  def initialize = (@a = +"init")
  def a = @a
  def a=(v)
    @a = v
  end
end

def id(x) = x
def mk(f) = f ? 3 : +"b"

def attempt(s)
  s << "!"
  "mutated"
rescue FrozenError
  "FrozenError"
end

# an instance variable's freeze kept in another one
p Keep.new(+"ab").go

# a method answering the freeze of an instance variable's write
o = Setter.new
s = +"s"
x = o.set(s)
p [x.equal?(s), x.equal?(o.a), x.frozen?, attempt(s)]

# a then block's tail
s = +"t"
t = s
r = t.then { _1.freeze }
p [r.frozen?, s.frozen?, r.equal?(s), attempt(t)]
s = +"u"
r = s.then { _1 << "1" }
p [r, s, r.equal?(s)]

# the answer of a method handed the String, beside an attribute assignment
b = Box.new
s = +"v"
b.a = s
r = id(s).freeze
p [r.frozen?, s.frozen?, r.equal?(s), b.a.frozen?]

# a boxed receiver's to_s
v = mk(ARGV.size == 0 ? false : true)
f = v.to_s.freeze
p [v.frozen?, f, attempt(v), v]

# a conditional with an attribute assignment's value for a branch
b = Box.new
s = +"w"
r = (s.empty? ? nil : (b.a = s)).freeze
p [b.a, s, r, b.a.frozen?, s.frozen?, r.equal?(s)]

# a safe-navigation chain over an explicit writer's assignment
w = Writer.new
s = +"y"
begin
  (w.a = s)&.freeze&.<<("!")
rescue => e
  p e.class
end
p [s, s.frozen?, w.a.equal?(s)]
s = +"z"
r = (w.a = s)&.freeze
p [r.frozen?, s.frozen?, r.equal?(s)]

# a begin's value, a block's next and a loop's break
s = +"b1"
r = begin
  s.freeze
rescue
  nil
end
p [r.frozen?, r.equal?(s)]
s = +"b2"
r = [1].map { next s.freeze }.first
p [r.frozen?, s.frozen?, r.equal?(s)]
s = +"b3"
r = loop { break s.freeze }
p [r.frozen?, r.equal?(s)]

# an argument and an Array element
def keep(x) = x
s = +"k1"
r = keep(id(s).freeze)
p [r.frozen?, s.frozen?, r.equal?(s)]
s = +"k2"
a = [(s << "x").freeze]
p [a[0].frozen?, a[0].equal?(s), s]

# freeze over freeze
s = +"ff"
p [s.freeze.freeze.equal?(s), s.frozen?]
