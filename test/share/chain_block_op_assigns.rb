# Under --share-strings (#6765): a block on a chain link that op-assigns the variable the chain is over
# (`@s += "x"` on an ivar the rule shares as a handle, `s += "y"`, `$g ||= ...`, an each_char block):
# the chain runs over the String it started from and `@s += x` on a handle ivar builds a new String.
class App
  def initialize(s) = (@s = s)
  def s = @s
  def m(v) = @s.tap { @s += "x" }.upcase! || v
  def n(v) = @s.each_char { |c| @s += "z" if c == "a" }.upcase! || v
end
b = +"abc"
a = App.new(b)
x = a.m(1)
p [x, x.equal?(b), a.s]
b = +"abc"
a = App.new(b)
x = a.n(1)
p [x, x.equal?(b), a.s]
def loc(v)
  s = +"abc"
  o = s
  x = s.tap { s += "y" }.itself || v
  [x, x.equal?(o), s]
end
p loc(1)
def glob(v) = $g.tap { $g ||= +"q"; $g += "w" }.upcase! || v
b = $g = +"abc"
x = glob(1)
p [x, x.equal?(b), $g]
