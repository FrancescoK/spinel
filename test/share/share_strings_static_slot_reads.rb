# Flag-only: without the flag (as on master) each read is a copy and misses the change.
# A global, a constant or a class variable the rule shares holds the shared
# handle, and a read of it is a String: a method taking a String gets the
# changed String, and so does a global's op-write or or-write in value
# position. A class variable's read and write are a String the same way. A
# String bound out of a splat into a parameter the rule shares is made the
# handle ahead of the call, in a rooted temp.

def f(v) = [v.size, v]

$g = +"g"
t = $g
t << "1"
p f($g)
p f($g += "2"), t
p f($g ||= "z")

X = +"x"
y = X
y << "1"
p f(X)

class C
  @@v = +"v"
  def self.add(x) = @@v << x
  def self.alias_add
    w = @@v
    add("3")
    w
  end
  def self.read = [@@v.size, @@v]
  def self.write(x) = [(@@v = x).size, x]
end
p C.alias_add, C.read, C.write(+"new"), C.read

def g1(a = nil, *r, z) = (a << "!" if a.is_a?(String); [a.size, r, z])
s = +"s"; u = s; s << ""
p g1(s, *[], 1), u
p g1(+"plain", *[2], 3)

# A global or a constant written from a String local that is master's own
# handle (#3227: `t = s` aliases s, which is then appended to) holds an
# sp_String * without the rule sharing it, and reads as a String too.
def sz(v) = v.size
a = +"a"
a << "b"
$m = (b = a)
p sz($m)
Z = (c = a)
p sz(Z)
$n = (d = a)
p sz($n += "c")
$q = (e = a)
p sz($q ||= "z")
