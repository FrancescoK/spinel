# spinel: gc-minor
# An Enumerator over a String (a blockless each_char, each_line, each_byte or
# each_codepoint) reads the String when it is walked, not when it is made: a
# walk (next, to_a, a block, size, an Enumerator built on it) sees what was
# changed in place before it started. each_char and each_line take the String
# as it is where the walk starts; each_byte's next reads byte by byte.

# a String two names share, changed through the other one
s = +"ab"
t = s
e = s.each_char
t.replace("zz")
p e.next, e.next
s = +"ab"
t = s
e = s.each_char
p e.next
t.replace("zz")
p e.next
e.rewind
p e.next

# the value of an attribute assignment and of a Struct member's
class C
  attr_accessor :a
  def initialize = (@a = +"init")
end
o = C.new
s = +"ab"
e = (o.a = s).each_char
s.replace("zz")
p e.next, e.next
S = Struct.new(:a)
so = S.new(+"init")
s = +"ab"
e = (so.a = s).each_char
p e.size
s << "c"
p e.size, e.to_a

# an explicit writer's
class W
  def initialize = (@a = +"init")
  def a = @a
  def a=(v)
    @a = v
  end
end
w = W.new
s = +"ab"
e = (w.a = s).each_char
w.a.replace("zz")
p e.next

# each kind, walked several ways
%w[x].each do
  s = +"ab\ncd"
  t = s
  eb = s.each_byte
  ec = s.each_codepoint
  el = s.each_line
  p eb.next, ec.next, el.next
  t.replace("XY\nZW")
  p eb.next, ec.next, el.next
  p eb.size, ec.size, el.size
  t << "\nq"
  p eb.to_a.size, ec.to_a.last, el.to_a
end
s = +"ab"
t = s
e = s.each_char
t << "c"
n = 0
e.each { |c| n += 1 }
p n, e.map(&:upcase), e.with_index.to_a, e.each_slice(2).to_a
p e.inspect
p e.peek, e.next
t << "d"
p e.next
w2 = e.with_index
t << "e"
p w2.to_a.last
begin
  loop { e.next }
rescue StopIteration
end
r = begin
  e.next
rescue StopIteration => ex
  ex.result
end
p r

# made and walked in one expression: the String as it is there
s = +"ab"
t = s
t << "c"
p s.each_char.to_a, s.each_byte.map { |b| b + 1 }

# a shared String read out of a container
h = { k: +"xy" }
z = h[:k]
z2 = z
f = [z, 1].first.each_char
z2 << "w"
p f.to_a, f.size

# each walk reads the items it started with: a #next run, and a walk with
# another walk or a change inside it
s = +"abc"
t = s
e = s.each_char
p e.next
t.replace("xyz")
p e.size, e.next, e.to_a
e.each { |c| print c }
puts
p e.next
begin
  e.next
rescue StopIteration
  p :stop
end
s = +"abc"
t = s
b = s.each_byte
p b.next, b.next, b.next
begin; b.next; rescue StopIteration; p :stop; end
t << "d"
begin; p b.next; rescue StopIteration; p :stop2; end
b.rewind
p b.next
s = +"abc"
t = s
b = s.each_byte
p b.peek
t.replace("xbc")
p b.next, b.next
s = +"ab"
t = s
e = s.each_char
e.each do |c|
  t << "Z" if t.size < 3
  print c, ":", e.to_a.join, " "
end
puts
s = +"abc"
t = s
e = s.each_char
e.each_with_index { |c, i| t.replace("Q") if i == 0; e.first; print c }
puts
s = +"ab"
t = s
b = s.each_byte
b.each { |c| t << "x" if t.size < 4; print c, " " }
puts

# next on an Enumerator built on one, and how it inspects
s = +"ab"
t = s
wi = s.each_char.with_index
t.replace("zz")
p wi.next, wi.to_a, wi.inspect
sl = s.each_char.each_slice(1)
t.replace("qq")
p sl.next, sl.size

# a kept cycle
s = +"ab"
t = s
cy = s.each_char.cycle
t.replace("mn")
p cy.take(3), cy.next, cy.next, cy.next

# a to_a the program writes is eager, also in a module's method
module CycleTo
  def go(s)
    e = s.each_char
    c = e.to_a.cycle
    s << "z"
    p c.take(4)
  end
end
class CycleK
  include CycleTo
end
CycleK.new.go(+"ab")
