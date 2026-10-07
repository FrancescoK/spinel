# Flag-only: a String stored into a constant's, a class variable's or an
# instance variable's Array whose elements the share rule shares, and then
# changed through a block parameter bound to the element. The constant's
# and the class variable's Array held the handles, but a String stored by
# `[]=`, `<<`, push, unshift, insert or prepend went in as a plain String:
# the change was lost. An instance variable's poly Array written from a new
# String Array (`s.split`) held its Strings plainly too. A local's insert
# and prepend lost it as well.
def bang(a) = a.each { |e| t = e; t << "!" }
A = "p q".split(" ")
A[1] = +"z"
A << +"y"
A.push(+"x")
A.unshift(+"w")
A.insert(2, +"v")
A.prepend(+"u")
bang(A)
p A
class K
  @@v = "p q".split(" ")
  def self.go
    @@v[0] = +"z"
    @@v << +"y"
    @@v.insert(1, +"x")
    @@v.each { |e| t = e; t << "?" }
    @@v
  end
end
p K.go
class H
  def initialize = (@a = "p q".split(" "))
  def go
    @a[1] = +"z"
    @a << +"y"
    @a.each { |e| t = e; t << "#" }
    @a
  end
end
p H.new.go
l = "p q".split(" ")
l.insert(1, +"z")
l.prepend(+"y")
l.each { |e| t = e; t << "%" }
p l
KEEP = []
keep = proc { |t| KEEP << t.upcase; KEEP << t; t.size }
s = +"k"
keep.call(s)
s << "!"
p KEEP
