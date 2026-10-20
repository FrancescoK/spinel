# The same read-alias-copy-mutate shape, `x = b.s; y = x; x = x.dup;
# x << "!" if x; y << "?" if y`, where one class answers its String member
# and another answers no String: `def s = nil`, or `def s = @n` of an
# instance variable only ever written nil. An arm that answers no String
# has none for another name to see, so the dispatch carries the member's
# handle beside it. The alias is written bare, in parentheses, under a
# sequence of statements and as the last of an array.
class Box
  def initialize; @s = +"abc"; end
  def s = @s
end

class Nothing
  def s = nil
end

class Unset
  def initialize; @n = nil; end
  def s = @n
end

def bare(b)
  x = b.s
  y = x
  x = x.dup
  x << "!" if x
  y << "?" if y
  p x, y
  p b.s
end

def paren(b)
  x = b.s
  y = (x)
  x = x.dup
  x << "!" if x
  y << "?" if y
  p x, y
  p b.s
end

def seq(b)
  x = b.s
  y = (puts "side"; x)
  x = x.dup
  x << "!" if x
  y << "?" if y
  p x, y
  p b.s
end

def last(b)
  x = b.s
  y = [x, (puts "side"; x)].last
  x = x.dup
  x << "!" if x
  y << "?" if y
  p x, y
  p b.s
end

[Box, Nothing].each do |k|
  bare(k.new)
  paren(k.new)
  seq(k.new)
  last(k.new)
end

def bare2(b)
  x = b.s
  y = x
  x = x.dup
  x << "!" if x
  y << "?" if y
  p x, y
end
def seq2(b)
  x = b.s
  y = (puts "side"; x)
  x = x.dup
  x << "!" if x
  y << "?" if y
  p x, y
end
bare2(Box.new)
bare2(Unset.new)
seq2(Box.new)
seq2(Unset.new)
