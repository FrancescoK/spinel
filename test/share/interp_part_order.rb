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

# a later part that rebinds an instance variable through a method keeps the
# String the earlier part named
class R
  def initialize = @s = +"iv"
  def s=(v)
    @s = v
  end
  def reset = (@s = +"z")
  def go = "#{@s}-#{reset}"
  def go2 = "#{@s}-#{self.s = +"new"}"
  def go3(o) = "#{@s}-#{o.reset}"
  def go4 = "#{@s}-#{send(:reset)}"
end
p R.new.go, R.new.go2, R.new.go3(R.new), R.new.go4

# adjacent literals are built one at a time
a1 = +"s"
p "#{a1}" "-#{a1 << "!"}"
a2 = +"t"
p "a#{a2}" "-#{a2 << "!"}" "#{a2}"

# a part that is the String itself through a method answering its receiver
m1 = +"x"
p "#{m1 << "a"}-#{m1 << "b"}"
m2 = +"y"
p "#{m2.concat("1")}|#{m2.concat("2")}"
m3 = +"u"
p "#{m3.replace("U")}#{m3 << "!"}"
m4 = +"b"
p "#{m4.itself}-#{m4 << "!"}"
m5 = +"c"
p "#{m5.to_s}-#{m5 << "?"}"
m6 = +"d"
p "#{m6.to_str}-#{m6 << "?"}"
m7 = +"e"
p "#{+m7}-#{m7 << "?"}"
m8 = +"f"
p "#{m8&.itself}-#{m8 << "?"}"
m9 = +"G"
p "#{m9.upcase!}|#{m9 << "h"}"
m10 = +"g"
p "#{m10.upcase!}|#{m10 << "h"}"

# a part of several statements that ends in the String
t1 = +"b"
p "#{t1 << "1"; t1}-#{t1 << "2"}"
t2 = +"a"
p "#{x = 1; t2 << "!"; t2}-#{x}-#{t2 << "?"}"
