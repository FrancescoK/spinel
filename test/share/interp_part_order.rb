# An interpolation holds each String part as the object it is until the
# whole string is built: CRuby evaluates every part, then concatenates, so a
# later part that changes the String in place shows in an earlier part's text
# (`"#{s}-#{s << "!"}"` is "abc!-abc!"). A part another part rebinds keeps the
# String it named, and an interpolation whose later parts change nothing is
# built as it always was.
def f(u) = (u << "?"; 1)

# locals
s = +"abc"
p "#{s}-#{s << "!"}"
t = +"x"
p "#{t}#{t.upcase!}#{t}"
u = +"q"
p "#{u}:#{f(u)}"
v = +"v"
w = v
p "#{v}-#{w << "1"}"

# rebinding keeps the part's String
a = +"a"
p "#{a}-#{(a = +"b")}"
b = +"b"
p "#{b}-#{b += "c"}"

# nothing later changes a String
c = +"c"
p "#{c}-#{c.size}-#{c + "!"}"

# instance variables, a method that answers one, and a reader
class K
  attr_reader :s
  def initialize = @s = +"iv"
  def m = @s
  def go = "#{@s}-#{@s << "!"}"
  def go2 = "#{m}-#{@s << "?"}"
  def go3 = "#{s}-#{@s << "#"}"
  def go4 = "#{@s}|#{@s.upcase!}|#{@s}"
end
k = K.new
p k.go, k.go2, k.go3, k.go4

# a name held by two variables, and a global
d = +"d"
e = d
p "#{d}-#{e << "x"}"
$g = +"g"
p "#{$g}-#{$g << "y"}"

# a boxed receiver's call whose arms answer a String
class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
px = ARGV.size == 0 ? PA.new : PB.new
r = +"abc"
p "#{px.pick(r)}-#{r << "!"}"
r2 = +"r"
p "#{px.pick(r2)}#{r2.upcase!}"

# nested interpolations
n = +"n"
p "<#{"#{n}-#{n << "1"}"}>"
n2 = +"m"
p "#{"#{n2}"}-#{n2 << "2"}"

# %Q, a heredoc, and symbols built by an interpolation
q = +"q"
p %Q(#{q}-#{q << "3"})
h = +"h"
x = <<~E
  #{h}|#{h << "4"}
E
p x
y = +"y"
p :"#{y}-#{y << "5"}"
z = +"z"
p %I[#{z} #{z << "6"}]

# a method that answers its argument
def one(str) = str
j = +"j"
p "#{one(j)}-#{j << "8"}"
