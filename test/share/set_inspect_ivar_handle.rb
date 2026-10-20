# An element's inspect (or to_s) that answers its own ivar's String, mapped
# by a block into the Array a container's inspect builds (Set#inspect's
# `@data.map { |x| x.inspect }`), hands on that String itself: the result
# kept in another container and changed in place, and the ivar's String
# changed through its other name, read as in CRuby (#9258). The neighbours:
# map(&:inspect), to_s, a Hash value, a join of the mapped Strings, the ivar
# changed before and after, a frozen ivar String and a second class whose
# inspect answers a new String.
require 'set'
class Node
  def initialize(label) = @label = label
  def inspect = @label
  def relabel(s) = @label << s
end
class Text
  def initialize(label) = @label = label
  def to_s = @label
end
class Leaf
  def inspect = +"lf"
end

# Set#inspect, kept and changed
lab = +"leaf"; all = []
s = Set.new([Node.new(lab)]); r = s.inspect
all << r; r << "!"; lab << "?"
p r, lab, all

# map(&:inspect) and a block's map
l2 = +"sym"
m = [Node.new(l2)].map(&:inspect)
all << m[0]; m[0] << "!"
p m, l2, m[0].equal?(l2)
b = [Node.new(l2)].map { |x| x.inspect }
b[0] << "+"
p b, l2

# to_s in place of inspect
l3 = +"text"
t = [Text.new(l3)].map { |x| x.to_s }
all << t[0]; t[0] << "!"; l3 << "?"
p t, l3
u = Set.new([Text.new(l3)]).to_a.map(&:to_s)
u[0] << "%"
p u, l3

# a Hash value
l4 = +"hv"
h = { a: Node.new(l4) }
hr = h.inspect
all << hr; hr << "!"; l4 << "?"
p hr, l4
hv = h.values.map { |x| x.inspect }
hv[0] << "#"
p hv, l4

# join of the mapped Strings
l5 = +"j1"
j = [Node.new(l5), Node.new(+"j2")].map { |x| x.inspect }.join(",")
all << j; j << "!"; l5 << "?"
p j, l5

# the ivar changed before and after the inspect
l6 = +"ba"
n = Node.new(l6)
n.relabel("-pre")
sr = Set.new([n]).inspect
all << sr; sr << "!"
n.relabel("-post")
p sr, l6, Set.new([n]).inspect

# a frozen ivar String
l7 = "frozen"
fr = Set.new([Node.new(l7)]).inspect
all << fr; fr << "!"
f = [Node.new(l7)].map { |x| x.inspect }
p fr, l7, f[0].frozen?, f[0].equal?(l7)

# a second class whose inspect answers a new String
l8 = +"two"
pr = Set.new([Node.new(l8), Leaf.new]).inspect
all << pr; pr << "!"; l8 << "?"
p pr, l8
pm = [Node.new(l8), Leaf.new].map { |x| x.inspect }
pm[0] << "*"; pm[1] << "*"
p pm, l8

p all
