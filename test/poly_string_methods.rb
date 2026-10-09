# spinel: share
# String methods on a poly receiver: a String that reached a slot the compiler
# could only type as poly (a container read, a parameter two call sites
# disagree about).
#
# #lines and #each_char had no poly arm at all, and #split lost its String arm
# whenever a user class owned the name -- the bundled Pathname does, so
# `require "pathname"` alone was enough to take it away. All three raised
# NoMethodError naming String, on a value that is a String.

require "pathname"

mixed = ["one two\nthree\n", 1]
s = mixed[0]

p s.lines
p s.split
p s.split(" ")
p s.split(nil)
p s.split(/\s+/)

acc = []
s.each_char { |ch| acc.push(ch) if ch == "o" }
p acc
p s.each_char { |ch| }.class

# the same names through a parameter two call sites disagree about
def widened(x)
  x
end
p widened("a b").split(nil)
p widened(1)

module Util
  module_function

  def wrap(str, columns = 0)
    str.split(nil).join("-")
  end

  def chars_of(str)
    out = []
    str.each_char { |c| out << c }
    out
  end

  def lines_of(str)
    str.lines
  end
end

def poly_seed
  t = {}
  Util.wrap(t)
end

p Util.wrap("one two")
p Util.chars_of("ab")
p Util.lines_of("x\ny\n")

# a Pathname still answers its own #split
pn = Pathname.new("/a/b")
p pn.split.map { |q| q.to_s }
