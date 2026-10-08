# sub! and gsub! answer nil when the call itself replaced nothing. The answer
# is read from the runtime's "a substitution was made" flag. An operand or a
# neighbour in the statement that ran a sub of its own left its answer there,
# and a block that ran a sub! of its own cleared it.

def swap(s) = s.sub("a", "b")

x = "ab".dup
y = "zz".dup
z = "ab".dup

# an argument that is a sub of its own; nothing in y matches
p y.sub!("q", z.sub("a", "b"))
p y.gsub!("q", z.sub("a", "b"))
p y.sub!(/q/, z.gsub(/a/, "b"))
p y.gsub!(/q/, z.sub(/a/, "b"))
p y.sub!("q", swap(z))
p y.sub!("q", z.gsub("a") { "b" })
p y.gsub!("q", (z.sub!("a", "a"); "r"))
p y

# the pattern
p y.sub!(z.sub("ab", "q"), "r")
p y.gsub!(z.gsub("a") { "q" }, "r")
p y

# a pattern only known at run time
pats = [z.sub("ab", "q"), /q/, 1]
p y.sub!(pats[0], z.sub("a", "b"))
p y.gsub!(pats[1], z.sub("a", "b"))

# a receiver held in a temporary: an instance, a class or a global variable
class Holder
  @@c = "zz".dup
  def initialize = @s = "zz".dup
  def ivar(z) = @s.sub!("q", z.sub("a", "b"))
  def self.cvar(z) = @@c.gsub!("q", z.sub("a", "b"))
end
$g = "zz".dup
p Holder.new.ivar(z)
p Holder.cvar(z)
p $g.sub!("q", z.sub("a", "b"))

# an argument the call converts with to_str, and a boxed replacement
class Conv
  attr_writer :z
  def to_str = @z.sub("a", "b")
end
conv = Conv.new
conv.z = z
p y.sub!("q", conv)
p y.gsub!(conv, "r")
p y.sub!("q", [z.sub("a", "b"), 1][0])
box = ARGV.size > 5 ? "r" : conv
p y.sub!("q", box)

# a block that runs a sub! of its own; x matches and keeps its text
p x.gsub!("a") { y.sub!("q", "-") ? "b" : "a" }
p x.sub!(/b/) { y.gsub!(/q/, "-") ? "a" : "b" }
p x.sub!("a") { y.sub!("q") { "-" } ? "b" : "a" }
p x

# the same on a String other names share
s = "zz".dup
t = s
p s.sub!("z") { y.sub!("q", "-") ? "y" : "z" }
p s.gsub!(/z/) { y.gsub!(/q/, "-") ? "y" : "z" }
p t

# two in one statement: the second is not answered by the first's match
p "#{x.sub!("a", "a").inspect} #{y.sub!("q", "-").inspect}"
puts "#{z.sub("a", "a")} #{y.gsub!(/q/, "-").inspect}"
n = z.sub("a", "a").size + (y.sub!("q", "-") ? 1 : 0)
p n

# as before: the call's own match, with or without a change of text
p x.sub!("a", "a")
p x.sub!("q", "r")
p x.gsub!("b") { y.sub("q", "-"); "b" }
p x.sub!("a", z.sub("a", "c"))
p x.gsub!(/c/) { z.sub("a", "a") }
p y.sub!("z", z.sub("q", ""))
p x, y, z
