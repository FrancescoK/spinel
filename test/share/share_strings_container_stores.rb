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
# An instance variable's Array takes insert and prepend as its other stores
# do, and a `||=` or `&&=` of a new String Array into an instance
# variable's or a class variable's Array wraps each String as its plain
# write does.
class I
  def initialize = (@a = "p q".split(" "))
  def go
    @a << +"y"
    @a.insert(1, +"z")
    @a.prepend(+"w")
    @a.each { |e| t = e; t << "!" }
    @a
  end
end
p I.new.go
class O
  def go
    @a ||= "p q".split(" ")
    @a << +"z"
    @a.each { |e| t = e; t << "&" }
    @a
  end
  def self.go
    @@b = ["x"].map { |x| x + "" }
    @@b &&= "r s".split(" ")
    @@b << +"t"
    @@b.each { |e| t = e; t << "^" }
    @@b
  end
end
p O.new.go, O.go

# A push or insert of more than 64 arguments, and an Array literal of as
# many elements, store every one of them: the 70th is shared like the first.
class W
  def initialize = (@a = "p q".split(" "))
  def go
    @a.push(+"s0", +"s1", +"s2", +"s3", +"s4", +"s5", +"s6", +"s7", +"s8", +"s9", +"s10", +"s11", +"s12", +"s13", +"s14", +"s15", +"s16", +"s17", +"s18", +"s19", +"s20", +"s21", +"s22", +"s23", +"s24", +"s25", +"s26", +"s27", +"s28", +"s29", +"s30", +"s31", +"s32", +"s33", +"s34", +"s35", +"s36", +"s37", +"s38", +"s39", +"s40", +"s41", +"s42", +"s43", +"s44", +"s45", +"s46", +"s47", +"s48", +"s49", +"s50", +"s51", +"s52", +"s53", +"s54", +"s55", +"s56", +"s57", +"s58", +"s59", +"s60", +"s61", +"s62", +"s63", +"s64", +"s65", +"s66", +"s67", +"s68", +"s69")
    @a.each { |e| t = e; t << "?" }
    [@a.last, @a.size]
  end
end
p W.new.go
a = "x y".split(" ")
a.push(+"s0", +"s1", +"s2", +"s3", +"s4", +"s5", +"s6", +"s7", +"s8", +"s9", +"s10", +"s11", +"s12", +"s13", +"s14", +"s15", +"s16", +"s17", +"s18", +"s19", +"s20", +"s21", +"s22", +"s23", +"s24", +"s25", +"s26", +"s27", +"s28", +"s29", +"s30", +"s31", +"s32", +"s33", +"s34", +"s35", +"s36", +"s37", +"s38", +"s39", +"s40", +"s41", +"s42", +"s43", +"s44", +"s45", +"s46", +"s47", +"s48", +"s49", +"s50", +"s51", +"s52", +"s53", +"s54", +"s55", +"s56", +"s57", +"s58", +"s59", +"s60", +"s61", +"s62", +"s63", +"s64", +"s65", +"s66", +"s67", +"s68", +"s69")
a.each { |e| t = e; t << "!" }
p a.last, a.size
b = "x y".split(" ")
b.insert(1, +"s0", +"s1", +"s2", +"s3", +"s4", +"s5", +"s6", +"s7", +"s8", +"s9", +"s10", +"s11", +"s12", +"s13", +"s14", +"s15", +"s16", +"s17", +"s18", +"s19", +"s20", +"s21", +"s22", +"s23", +"s24", +"s25", +"s26", +"s27", +"s28", +"s29", +"s30", +"s31", +"s32", +"s33", +"s34", +"s35", +"s36", +"s37", +"s38", +"s39", +"s40", +"s41", +"s42", +"s43", +"s44", +"s45", +"s46", +"s47", +"s48", +"s49", +"s50", +"s51", +"s52", +"s53", +"s54", +"s55", +"s56", +"s57", +"s58", +"s59", +"s60", +"s61", +"s62", +"s63", +"s64", +"s65", +"s66", +"s67", +"s68", +"s69")
b.each { |e| t = e; t << "!" }
p b[70], b.size
c = [+"s0", +"s1", +"s2", +"s3", +"s4", +"s5", +"s6", +"s7", +"s8", +"s9", +"s10", +"s11", +"s12", +"s13", +"s14", +"s15", +"s16", +"s17", +"s18", +"s19", +"s20", +"s21", +"s22", +"s23", +"s24", +"s25", +"s26", +"s27", +"s28", +"s29", +"s30", +"s31", +"s32", +"s33", +"s34", +"s35", +"s36", +"s37", +"s38", +"s39", +"s40", +"s41", +"s42", +"s43", +"s44", +"s45", +"s46", +"s47", +"s48", +"s49", +"s50", +"s51", +"s52", +"s53", +"s54", +"s55", +"s56", +"s57", +"s58", +"s59", +"s60", +"s61", +"s62", +"s63", +"s64", +"s65", +"s66", +"s67", +"s68", +"s69"]
c.each { |e| t = e; t << "#" }
p c.last, c.size
