# freeze over a receiver that can be nil answers nil for nil (NilClass#freeze)
# and the receiver itself, frozen, otherwise, through a conditional, a then
# block, an Array element, a method's value, a begin, a safe-navigation call
# and an attribute assignment; an explicit writer that dups keeps its copy
# unfrozen, since the assignment's value is the right-hand side; a bang that
# answers nil hands freeze its nil.
class Box
  attr_accessor :a
  def initialize = (@a = +"x")
end

class Dup
  def initialize = (@a = +"init")
  def a = @a
  def a=(v)
    @a = v.dup
  end
end

def id(x) = x
none = ARGV.empty?

s = +"s"
p (none ? nil : s).freeze, s.frozen?
p (s if !none).freeze
p (none ? nil : s).then { _1.freeze }
p [(none ? nil : s).freeze]
p id(none ? nil : s).freeze
r = begin
  (none ? nil : s).freeze
end
p r
p (none ? nil : s).freeze.equal?(s)
t = +"t"
q = (none ? t : nil).freeze
p q.equal?(t), t.frozen?

o = Box.new
e = +""
p (e.empty? ? nil : (o.a = e)).freeze, e.frozen?
f = +"f"
r = (f.empty? ? nil : (o.a = f)).freeze
p [o.a, r, f.frozen?, r.equal?(f)]

u = +"u"
p (none ? nil : u)&.freeze, u.frozen?
p (!none ? (o.a = u) : nil)&.freeze
v = +"v"
r = (none ? v : nil)&.freeze
p r.equal?(v), v.frozen?

w = Dup.new
kept = w.a
kept << "!"
d = +"d"
r = (none ? (w.a = d) : nil).freeze
p r.frozen?, d.frozen?, w.a.frozen?, r.equal?(d), kept
held = w.a
held << "?"
p w.a

# freeze over a method answering the String it was handed, and over a bang
# on it, which answers that String or nil
g = +"g"
k = id(g).freeze
p k.equal?(g), g.frozen?
h = +"h"
k = id(h).upcase!.freeze
p k.equal?(h), h.frozen?, h
j = +"J"
k = id(j).upcase!.freeze
p k, j.frozen?
