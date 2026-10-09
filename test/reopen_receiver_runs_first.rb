# spinel: gc-stress
# The receiver of a call into a method the program adds to a builtin runs
# before the call's arguments, as it does for a class's own method, and is
# held while a rest or a default is made beside it.

$log = []

class Object
  def pair(a, *r) = "#{a.size} #{r.size}"
  def rest(*r) = "#{r.size} #{label}"
  def dflt(o = [1, "d", nil]) = "#{o.size} #{label}"
end

class String
  def pair(a) = "#{size} #{a.size}"
end

class Array
  def pair(a, b = 1) = "#{size} #{a.size} #{b}"
end

class Hash
  def pair(a) = "#{size} #{a.size}"
end

class Integer
  def pair(a, *r) = "#{self} #{a.size} #{r.size}"
end

class Numeric
  def pair2(a) = "#{self} #{a.size}"
end

class Symbol
  def pair(a) = "#{self} #{a.size}"
end

class Door
  def initialize
    @name = "door" + ARGV.size.to_s
    @parts = []
    2000.times { |i| @parts << [i, "p", nil] }
  end
  def label = @name
end

def door
  $log << "door"
  Door.new
end

def str
  $log << "str"
  "s" + ARGV.size.to_s
end

def ary
  $log << "ary"
  [1, "a", nil]
end

def hsh
  $log << "hsh"
  { "k" => ARGV.size }
end

def int
  $log << "int"
  ARGV.size + 4
end

def flt
  $log << "flt"
  ARGV.size + 4.5
end

def sym
  $log << "sym"
  ARGV.size > 0 ? :b : :a
end

def arg
  $log << "arg"
  [1, "a"]
end

puts door.pair(arg)
puts str.pair(arg)
puts ary.pair(arg)
puts hsh.pair(arg)
puts int.pair(arg)
puts flt.pair2(arg)
puts sym.pair(arg)
puts $log.join(" ")

# a rest, a splat and a default made in place beside a receiver built there
xs = [1, 2, ARGV.size]
puts Door.new.rest
puts Door.new.rest
puts door.rest(*xs)
puts Door.new.dflt
puts door.dflt

# an argument that only reads reads what the receiver left
$g = "g"
def setg
  $g = "set"
  "s" + ARGV.size.to_s
end
puts setg.pair($g)
$g = "g"
puts setg.pair("#{$g}!")
puts((x = "x" + ARGV.size.to_s).pair("#{x}!"))

# a String another name holds is read after an argument that changes it in
# place, as it was before: held ahead of it, it would be the String as it was
$s = +"ab"
def cur
  $log << "cur"
  $s
end
def add
  $s << "c"
  [1, 2]
end
puts cur.pair(add)
def app(s)
  s << "xyz"
  [1]
end
t = +"t"
puts (t << "1").pair(app(t))

# an argument that runs the program's own code keeps its place: the hash of
# a key the program defines runs before the String another name holds is read
$k = +"ab"
class Key
  def hash
    $k << "d"
    1
  end
  def eql?(o) = true
end
class String
  def many(*r) = "#{size} #{r.size}"
end
def held = $k
key = Key.new
puts held.many({ key => 1 })

# a String from a call is held ahead of such an argument only where the call
# makes its own: clamp answers its receiver, and a method the program gives
# Object may answer a String another name holds
$c = +"ab"
def addc
  $c << "c"
  [1, 2]
end
class Object
  def kept = $c
end
puts $c.clamp("a", "zz").pair(addc)
puts "x".kept.pair(addc)

# an interpolation is held ahead of such an argument only where CRuby makes
# a new String for it: a literal part with no text (a backslash at the end
# of its line) makes none, and the String another name holds is answered
$d = +"ab"
def addd
  $d << "c"
  [1, 2]
end
def joined = "#{$d}\
"
def tagged = "#{$d}!"
puts joined.pair(addd)
puts tagged.pair(addd)
