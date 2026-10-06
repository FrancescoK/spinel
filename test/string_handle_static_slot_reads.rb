# A global or a constant written from a String local that is an
# sp_String * handle without --share-strings (master's shared-mutable
# String, #3227: `t = s` aliases s, which is then appended to) holds a
# handle in its slot, and its read is a String: a method taking a String
# compiled and answered. So does a global's op-write and or-write in value
# position. A class variable's read and write in value position stay a
# String too.

def f(v) = v.size

s = +"a"
s << "b"
$g = (t = s)
p f($g)

X = (u = s)
p f(X)

$h = (w = s)
p f($h += "c"), $h, s

$k = (x = s)
p f($k ||= "z"), $k

class C
  def self.put(v) = (@@c = v)
  def self.get = @@c
  def self.size_of_put(v) = (@@c = v).size
end
C.put(s)
p C.get.size, C.size_of_put(+"xyz"), C.get
