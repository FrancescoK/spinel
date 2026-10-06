# Flag-only: without the flag (as on master) this program is refused.
# Shapes that answered as CRuby with the flag off and failed only under
# --share-strings: a block-mapped Hash key beside values changed in place,
# a boxed line matched with =~, a class reached by a dynamic `new` whose
# String parameter is the shared handle, and a prepend of several Strings
# answering its receiver.
def make_hash
  h = {}
  (1..3).each { |i| h["k#{i}"] = "v#{i}" }
  h
end
r = make_hash.transform_keys { |k| k.upcase }
p r
h = make_hash
h.each { |_k, v| v << "!" }
p h
module Lines
  def each_line
    @lines.each { |l| yield l }
    self
  end
end
class Sock
  include Lines
  def initialize(lines) = @lines = lines
end
def parse(raw)
  out = []
  raw.each_line { |line|
    if /^(\w+):/ =~ line
      value = line
      value.slice!(-1..-1)
      out << [$1, value]
    end
  }
  out
end
p parse("a: 1\nb: 2\n")
p parse(Sock.new([+"c: 3\n"]))
class Holder
  def initialize(n = 0, b)
    @n = n
    @b = b
  end
  def at(i) = @b.getbyte(i)
end
class Mutator
  def initialize(b) = @b = b
  def poke(i, v) = @b.setbyte(i, v)
end
def constantly(k) = k
s = +"abcd"
Holder.new(0, s)
Mutator.new(s).poke(2, 7)
p constantly(Holder).new(0, s).at(2)
class PrependHolder
  def run
    @s = +"a"
    t = @s
    t << "!"
    r = (@s << "x").prepend("p", "q")
    r3 = @s.prepend("m", "n")
    r3 << "z"
    p @s, r.equal?(@s), r3.equal?(@s)
  end
end
PrependHolder.new.run
def lp
  s = +"a"
  r = s.prepend("x", "y")
  r << "!"
  p s, r.equal?(s)
end
lp
