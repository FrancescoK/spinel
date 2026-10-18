# A block run by a boxed receiver's builtin arm (an Array's each_cons,
# beside a class of the program's own that defines it too) calls a method
# a class of the program defines under a name a builtin also has (`b`,
# String#b): the call dispatches on its own receiver. The arm's reading of
# its receiver, as no object of the program's, reached the block's calls,
# and `t.b` ran String#b on a Tok, raising NoMethodError.

class Tok
  attr_reader :b
  def initialize(b) = @b = b
  def size = @b * 10
end

class Node
  def initialize(e) = @e = e
  def each_cons(n, &blk) = @e.each_cons(n, &blk)
end

def pick(a, i) = a[i]
v = pick([[Tok.new(1), Tok.new(2), Tok.new(3)], Node.new([Tok.new(5), Tok.new(2)])], 0)
v.each_cons(2) { |t1, t2| p [t1.b, t2.b, t1.size] }
w = pick([[Tok.new(1)], Node.new([Tok.new(5), Tok.new(2)])], 1)
w.each_cons(2) { |t1, t2| p [t1.b, t2.b] }
pick([["x", "y"], Node.new([])], 0).each_cons(2) { |s1, s2| p [s1.b, s2.size] }
