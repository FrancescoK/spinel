# A String that is claimed unshared is never changed in place while a second
# name can reach it. unshared_claims.claims claims that of every new
# String below (the check is `unshared`, made where the String is changed); the
# oracle must disprove the Strings changed while a second name that is read
# again holds them (a local, a global, an ivar, a parameter of the method that
# changes it), and not the ones changed while one name holds them, or a second
# name that is dead, the standard library's or a Proc's own, or `self`.
$g = nil

class Holder
  attr_accessor :s
end

def grow(s) = s << "+"

class String
  def shout! = upcase!
end

alone = +"alone"
alone << "!"
p alone

pair = +"pair"
other = pair
pair << "?"
p other

glob = +"glob"
$g = glob
glob << "#"
p $g

h = Holder.new
iv = +"iv"
h.s = iv
iv << "~"
p h.s

dead = +"dead"
gone = dead
dead << "x"
p dead

arg = +"arg"
grow(arg)
p arg

grow(+"temp")

loud = +"loud"
loud.shout!
p loud

all = [+"a", +"b"]
all.each { |e| e << "." }
p all

cap = +"cap"
pr = proc { cap }
cap << "!"
p pr.call

cur = +"cur"
prev = cur
cur << "1"
prev = nil
p cur

uni = [0x65, 0x301].pack("U*")
uni.unicode_normalize!
p uni.size

require "pp"
out = +""
PP.pp([1, 2], out)
p out
