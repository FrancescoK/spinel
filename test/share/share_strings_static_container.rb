# Flag-only: a constant's or a class variable's String Array or Hash whose
# elements the share rule shares (a String stored into it, or a block
# parameter bound to its elements, is changed in place through another name)
# was refused under --share-strings when its literal holds Strings ("a typed
# String container cannot hold the shared handle yet"), and otherwise held
# copies: a change through the other name was lost. It now holds the handles
# as a global's does: a String Array settles in its poly form, and what its
# writes and stores give it is demanded into the handle. (The default build
# stores copies here and answers all but the first group wrong, as it does
# on master, or refuses the last.)
KEEP = ["seed"]
s = +"k"
KEEP << s
KEEP[1] << "!"
p s, KEEP
s << "?"
p KEEP
H = {"a" => "seed"}
t = +"h"
H["b"] = t
H["b"] << "!"
p t, H
module M
  NAMES = ["a"]
end
u = +"b"
M::NAMES << u
u << "!"
p M::NAMES
class Reg
  @@k = ["seed"]
  def self.add(s) = (@@k << s)
  def self.k = @@k
end
v = +"c"
Reg.add(v)
v << "!"
p Reg.k
Reg.k[1] << "?"
p Reg.k, v
# a block parameter bound to such a constant's elements, which it changes
# and hands on: the folded map and select, each, and the constant reached
# through a method
SRC = ["x", "y"].map { |s| s + "" }
def src = SRC
kept = []
r = SRC.map { |e| e << "!"; kept << e; e.size }
p r, SRC, kept
SRC.each { |e| e << "?" }
b = src.select { |e| e << "#"; kept << e; true }
kept[0] << "&"
p SRC, b, kept
