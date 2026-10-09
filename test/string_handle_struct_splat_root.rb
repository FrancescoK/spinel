# A String handed to a member or a parameter that is changed in place gets
# a handle of its own where it is handed over. Nothing held that handle
# when the String went to a Struct's member, or came out of a splatted
# Array, while the argument beside it or the object itself was allocated.
# Each line counts the objects that came out holding another String; the
# last one shows the members are changed in place.
# spinel: gc-stress
N = 4_000

class Pair
  attr_reader :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end
  def is?(odd) = odd ? @x == "s" && @y == "t" : @x == "q" && @y == "r"
end

class Tail
  attr_reader :x, :y
  def initialize(x, y = "r")
    @x = x
    @y = y
  end
  def is?(odd) = @x == (odd ? "s" : "q") && @y == "r"
end

Entry = Struct.new(:a, :b)

d = Pair.new(+"w", +"v")
d.x << "z"
d.y << "z"
g = Tail.new(+"w", +"v")
g.x << "z"
g.y << "z"
w = +"w"
v = +"v"
e = Entry.new(w, v)
e.a << "z"
e.b << "z"

# Each object is looked at one construction later, when a String it lost
# has been handed out again.
def wrong(n)
  bad = 0
  prev = nil
  n.times do |i|
    k = yield(i.odd?)
    bad += 1 if prev && !prev.is?(i.even?)
    prev = k
  end
  bad
end

def wrong_entries(n)
  bad = 0
  prev = nil
  n.times do |i|
    k = yield(i.odd?)
    if prev
      good = i.even? ? prev.a == "s" && prev.b == "t" : prev.a == "q" && prev.b == "r"
      bad += 1 unless good
    end
    prev = k
  end
  bad
end

ra = ["r"]
ta = ["t"]
qa = ["q"]
sa = ["s"]

# Kept, the objects are looked at when all of them are made.
kept = []
600.times { kept << Entry.new("alpha", "beta") }
p kept.count { |k| k.a != "alpha" || k.b != "beta" }
pairs = []
600.times { pairs << Pair.new("q", *ra) }
p pairs.count { |k| k.x != "q" || k.y != "r" }

p wrong(N) { |odd| odd ? Pair.new("s", *ta) : Pair.new("q", *ra) }            # an Array's element, splatted
p wrong(N) { |odd| odd ? Tail.new(*sa) : Tail.new(*qa) }                      # a splat that leaves a default to fill
p wrong_entries(N) { |odd| odd ? Entry.new("s", "t") : Entry.new("q", "r") }  # literals to a Struct
p [d.x, d.y, g.x, g.y, e.a, e.b, w, v]

# A number's operator the program defines itself runs the program's code,
# and allocates: its answer beside a literal is held as a call's answer
# is. clang is where it showed; gcc builds the list in the other order.
class Float
  def -@
    ["a" + to_s, "b"].size.to_f
  end
end

MixF = Struct.new(:a, :x)
wf = +"w"
mf = MixF.new(wf, 1.5)
mf.a << "z"
f = 2.5
mixed = []
600.times { mixed << MixF.new("alpha", -f) }
p mixed.count { |k| k.a != "alpha" || k.x != 2.0 }

# A default that reads a global and adds to it runs nothing.
class Num
  attr_reader :s, :n
  def putn(s, n)
    @s = s
    @n = n
    self
  end
end

nu = Num.new.putn(+"w", 1)
nu.s << "z"
$k = 5
def mkd(x, n = $k + 1) = Num.new.putn(x, n)
nums = []
600.times { nums << mkd(*qa) }
p nums.count { |k| k.s != "q" || k.n != 6 }
p [mf.a, wf, nu.s]

# An Integer's comparison hands an operand that is no number to that
# operand's own coerce, which allocates: such an operand is not a plain
# value.
class Meters
  def initialize(v)
    @v = v
  end
  def coerce(n) = [["a" + n.to_s, "b"].size, @v]
end

MixC = Struct.new(:a, :x)
wc = +"w"
mc = MixC.new(wc, 1)
mc.a << "z"
j = 5
mo = Meters.new(3)
coerced = []
600.times { coerced << MixC.new("alpha", (j > mo ? 1 : 2)) }
p coerced.count { |k| k.a != "alpha" || k.x != 2 }
p [mc.a, wc]
