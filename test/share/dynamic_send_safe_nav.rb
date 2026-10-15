# A safe-navigation send with a computed name answers nil for a nil
# receiver, and for any other the String its arm answers: a method answering
# a String or nil, a variable that is nil, a String variable. It tests the
# receiver for nil before the name and the arguments run, and the call sees
# the String those arguments changed in place.
$gs = +"abc"
def snil = nil
def smaybe(f) = f ? $gs : nil
sm = [:size, :to_s]
p snil&.send(sm[0])
p smaybe(false)&.send(sm[0])
u = smaybe(true)&.send(sm[1]); u << "S"; p $gs
sx = nil
p sx&.send(sm[0])
sy = +"sy"
u = sy&.send(sm[1]); u << "!"; p sy

# arguments that change the receiver in place
NM = [:center, :ljust, :to_s, :itself]
a = +"ab"
p a&.send(NM[0], (a << "!"; 7))
b = +"ab"
p b&.send(NM[0], (b.upcase!; 6))
c = +"ab"
p c&.send(NM[0], (c.replace("xyz"); 7))
def mutate(x) = (x << "#"; 7)
d = +"ab"
p d&.send(NM[0], mutate(d))
e = +"ef"
p e&.send(NM[0], 7, (e << "#"; "*"))
g = +"x"
out = []
4.times { |i| out << g&.send(NM[i % 2], (g << "y"; 8)) }
p out
lam = +"ll"
bump = -> { lam << "L"; 7 }
p lam&.send(NM[0], bump.call)
# ... a receiver that is a call, an instance variable, a global
class Holder
  def initialize = @s = +"iv"
  def s = @s
  def reader = s&.send(NM[0], (s << "!"; 7))
  def ivar = @s&.send(NM[1], (@s << "?"; 8))
  def keep = @s&.send(NM[0], (@s = +"new"; 9))
end
h = Holder.new
p h.s&.send(NM[0], (h.s << "$"; 8))
p h.reader
p h.ivar
p h.keep
$gv = +"gl"
p $gv&.send(NM[1], ($gv << "g"; 8))
# ... an argument that assigns the receiver's variable leaves the call on
# the String it had
z = +"xy"
p z&.send(NM[0], (z = +"q"; 5))
# a nil receiver runs none of its arguments, the name included
$log = []
def tick(x) = ($log << x; x)
p snil&.send(NM[0], tick(9))
p snil&.send((tick(:name); NM[0]), tick(8))
p sx&.send(NM[1], (sx = +"x"; tick(5)))
p sx, $log
# ... and code the arguments run, which can assign the variable with no
# assignment in sight, leaves a send on the String it had as before
class Shown
  def to_s = ($gs = +"new"; "o")
end
$gs = +"gl"
tt = +""
p $gs&.send(NM[0], (tt << "x"; "#{Shown.new}".size + 6))
p $gs
