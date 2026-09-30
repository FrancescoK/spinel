# A zero-length String#slice! at a position inside the String (or at its
# end) answers "" and leaves the receiver alone; out of range answers nil.
def show(label, r, s) = p([label, r, s])
s = String.new("abc"); r = s.slice!(1, 0); show("1, 0", r, s)
s = String.new("abc"); r = s.slice!(0, 0); show("0, 0", r, s)
s = String.new("abc"); r = s.slice!(3, 0); show("3, 0", r, s)
s = String.new("abc"); r = s.slice!(-1, 0); show("-1, 0", r, s)
s = String.new("abc"); r = s.slice!(4, 0); show("4, 0", r, s)
s = String.new("abc"); r = s.slice!(-4, 0); show("-4, 0", r, s)
s = String.new("abc"); r = s.slice!(1, -1); show("1, -1", r, s)
s = String.new("abc"); r = s.slice!(1...1); show("1...1", r, s)
s = String.new("abc"); r = s.slice!(1..0); show("1..0", r, s)
s = String.new("abc"); r = s.slice!(3..); show("3..", r, s)
s = String.new("abc"); r = s.slice!(3..5); show("3..5", r, s)
s = String.new("abc"); r = s.slice!(2..-3); show("2..-3", r, s)
s = String.new("abc"); r = s.slice!(4..); show("4..", r, s)

# an endless Range runs to the end
s = String.new("abc"); r = s.slice!(0..); show("0..", r, s)
s = String.new("abc"); r = s.slice!(-3..); show("-3..", r, s)
s = String.new("abc"); r = s.slice!(1..); show("1..", r, s)
s = String.new("abc"); r = s.slice!(0...); show("0...", r, s)
s = String.new("abc"); r = s.slice!(-4..); show("-4..", r, s)
s = String.new("abc"); r = s.slice!(-4...0); show("-4...0", r, s)
a = 0
s = String.new("abc"); r = s.slice!(a..); show("a..", r, s)
b = -3
s = String.new("abc"); r = s.slice!(b..); show("b..", r, s)

# the receivers: an instance variable, a String read out of a container
class K
  def initialize = @s = +"abc"
  def go = [@s.slice!(1, 0), @s.slice!(3..), @s]
end
p K.new.go
b = ["abc".dup, 1][0]
p b.slice!(1, 0), b
p b.slice!(3..), b
d = "héllo wörld".dup
p d.slice!(6, 0), d
p d.slice!(11..), d
p d.slice!(12..), d

# a non-empty slice, and one index, as before
s = String.new("abc"); r = s.slice!(1, 2); show("1, 2", r, s)
s = String.new("abc"); r = s.slice!(1..1); show("1..1", r, s)
s = String.new("abc"); r = s.slice!(0); show("0", r, s)
s = String.new("abc"); r = s.slice!(3); show("3", r, s)
s = String.new("abc"); r = s.slice!(2, 5); show("2, 5", r, s)
