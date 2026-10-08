# String#eql? is value equality, so a String that is a shared handle -- a
# reader over an ivar that is mutated through an alias, or a local stored in
# a container -- compares by its text like any other String. The identity
# rules that hand such operands a handle for equal? used to take eql? too,
# and the String arm then answered a constant false for the handle.
# spinel: gc-minor
class Names
  attr_reader :first, :last
  def initialize; @first = +"Ada"; @last = +"Bob"; end
end
nm = Names.new
f = nm.first; f << "!"
g = nm.last; g << "?"

p nm.first.eql?(nm.first)
p nm.first == nm.first
p nm.first.eql?(nm.last)
a = nm.first; b = nm.first
p a.eql?(b)
p a.eql?("Ada!")
p "Ada!".eql?(a)
p a.eql?(nm.last)
p a.equal?(b)
p a.equal?(nm.last)

# a local that a container shares
s = +"ab"
arr = [s]
s << "c"
p s.eql?(+"abc")
p s.eql?(arr[0])
p arr[0].eql?("abc")
p "abc".dup.eql?(s)
p s.eql?("abd")
p s.equal?(arr[0])

# two locals sharing buffers: both reads are copies, and the receiver's is
# rooted while the argument's is built (long, equal-length strings, so that
# under SPINEL_GC_STRESS a freed receiver is overwritten; gc-minor-test)
class Long
  attr_reader :x, :y
  def initialize; @x = "C" * 3000; @y = "D" * 3000; end
end
lg = Long.new
lx = lg.x; lx << "!"
ly = lg.y; ly << "?"
u = lg.x; v = lg.y
p u.eql?(v)
p u.eql?(lg.x)

# a poly argument holding a fresh String, against a receiver whose read is a
# copy: the receiver is read first, so the copy is not made while the
# argument's String is held only by a temp
def pick_long(f) = f ? ("C" * 3001) : 1
def pick_same(f) = f ? ("C" * 3000 + "!") : 1
p u.eql?(pick_long(true))
p u.eql?(pick_same(true))
p u.eql?(pick_long(false))
