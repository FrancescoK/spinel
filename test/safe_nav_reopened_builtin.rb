# spinel: gc-stress
# `s&.pair(1)` skips the call when s is nil, for a method the program adds to
# String, Integer or Float as for any other. The reopened method is asked for
# ahead of the builtin arms, and that question ran ahead of the nil guard too:
# the method was called on the nil and its arguments ran.

class String
  def pair(a) = "#{self}-#{a}"
  def upcase = "own #{self}"
end

class Integer
  def pair(a) = "#{self}-#{a}"
  def succ = self + 100
end

class Float
  def pair(a) = "#{self}-#{a}"
end

$ran = []
def tick(n) = ($ran << n; n)

def str(v) = v&.pair(tick(1))
p str(nil), str("s")

def int(v) = v&.pair(tick(2))
p int(nil), int(3)

def flt(v) = v&.pair(tick(3))
p flt(nil), flt(2.5)

# a builtin's name the program redefines
def up(v) = v&.upcase
p up(nil), up("s")
def nx(v) = v&.succ
p nx(nil), nx(3)

# the value used: a chain, a fallback, an interpolation, a condition
def chain(v) = v&.pair(tick(4))&.size
p chain(nil), chain("s")
def fallback(v) = v&.pair(tick(5)) || "none"
p fallback(nil), fallback(3)
def shown(v) = "<#{v&.pair(tick(6))}>"
p shown(nil), shown(2.5)
def asked(v) = v&.pair(tick(7)) ? "y" : "n"
p asked(nil), asked("s")

# each argument ran once, for the calls that were made
p $ran

# a local and an instance variable
s = ARGV.size > 0 ? "s" : nil
p s&.pair(tick(8))
class Box
  def initialize(v) = @v = v
  def show = @v&.pair(9)
end
p Box.new(nil).show, Box.new(4).show
p $ran.size

# a name a numeric arm answers ahead of the plain call: the program's own
# stands there, and nil still skips it
class Co
  def coerce(n) = [n, 5]
end
class Integer
  def numerator = 99
  def <=>(o) = 7
end
i = ARGV.size > 0 ? nil : 3
j = ARGV.size > 0 ? 3 : nil
p i&.numerator, j&.numerator
p i&.<=>(Co.new), j&.<=>(Co.new)

# a method that answers nothing, with an argument made in place: the guard
# is a statement then, and has no value to hold
class String
  def note(a) = puts("note #{self} #{a}")
end
class Integer
  def note(a) = nil
end
t = "x"
u = ARGV.size > 0 ? nil : "u"
u&.note(t + "y")
s&.note(t + "y")
p i&.note([1, 2]), j&.note([1, 2])

# the call stays where it stands: what the statement runs before it (an
# operand, the receiver's own call) still runs before it
$log = []
class String
  def info(m) = ($log << "info:#{m}"; 7)
end
class Integer
  def info(m) = ($log << "info:#{m}"; 7)
end
def side = ($log << "side"; "s")
def mk = ($log << "mk"; ARGV.size > 5 ? nil : "r")
w = ARGV.size > 5 ? nil : "r"
n = ARGV.size > 5 ? nil : 4
puts "#{side} <#{w&.info(t + "a")}> #{side}"
x = side + (n&.info(t + "b") ? "1" : "2")
puts x
puts "#{side} #{mk&.info("c")}"
puts "#{side} #{n&.info(t + "d") ? 1 : 2}"
p [side, mk&.info(t + "e"), side]
puts $log.join(",")

# the receiver outlives what its arguments make: a call's answer, a local
# and an instance variable, beside an argument that allocates
def fresh(k) = k > 5 ? nil : "f" + k.to_s
class Tag
  def initialize(v) = @v = v
  def held = @v&.pair([1, 2].inspect)
end
loc = fresh(ARGV.size)
p fresh(ARGV.size)&.pair([1, 2]), loc&.pair([3].inspect)
p Tag.new(fresh(ARGV.size)).held, fresh(9)&.pair([4])

# a String is read after an argument that changes it in place, as it was
# without the guard: held ahead of it, it would be the String as it was
def add(s) = (s << "c"; [1, 2])
q = +"ab"
p q&.pair(add(q).size)
$q = +"ab"
def addg = ($q << "c"; 2)
def cur = $q
p $q&.pair(addg), cur&.pair(addg)

# an argument that runs the program's own code keeps its place beside a
# receiver that is a call, and a receiver whose read runs it runs once
$k = +"ab"
class Key
  def hash = ($k << "d"; 1)
  def eql?(o) = true
end
class String
  def many(*r) = "#{self}-#{r.size}"
end
def held = $k
$at = 0
class Array
  def [](i) = ($at += 1; "x")
end
key = Key.new
p held&.many({ key => 1 })
ys = ["y", "z"]
p ys[0]&.pair(1), $at
