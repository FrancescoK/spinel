# `obj.attr ||= v` / `&&=` through a generated attribute or a Struct member,
# on an object whose slot was never assigned (#5428).

class Box
  attr_accessor :list, :map, :name, :count, :kind, :child, :ratio, :flag
end
Pair = Struct.new(:left, :right)

$calls = 0
def fresh
  $calls += 1
  ["made"]
end

# the slot is typed by a write on another object; this one is still nil
Box.new.list = %w[seed]
b = Box.new
b.list ||= []
b.list << "a"
p b.list

# ||= keeps a set value and does not evaluate the RHS
b.list ||= fresh
p [b.list, $calls]
c = Box.new
c.list ||= fresh
p [c.list, $calls]

# each slot kind, unset
b.map ||= {}
b.map[:k] = 1
b.name ||= "anon"
b.count ||= 7
b.kind ||= :draft
b.child ||= Box.new
b.ratio ||= 1.5
b.flag ||= true
p [b.map, b.name, b.count, b.kind, b.child.class, b.ratio, b.flag]

# a false flag is replaced, like nil
g = Box.new
g.flag = false
g.flag ||= true
p g.flag

# value form answers the assigned-or-existing value
d = Box.new
got = (d.list ||= ["v"])
p got
p (d.list ||= ["ignored"])

# &&= assigns only when set
e = Box.new
e.name &&= "never"
p e.name
e.name = "x"
e.name &&= "y"
p e.name

# a Struct member
s = Pair.new
s.left ||= []
s.left << 1
s.right ||= "r"
p s

f = Box.new
p f.list
f.list ||= []
p f.list.empty?
