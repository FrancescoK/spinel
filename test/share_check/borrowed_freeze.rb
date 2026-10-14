# A freeze of a String variable's read, a local, an instance variable or a
# global, reads that variable's bytes for the frozen String it answers and
# freezes the String the variable holds, so every other name of it, an
# Array or Hash element, an instance variable and the answer itself read it
# frozen. The freeze reaches the String through the variable, not through
# the bytes the read gives.
def frozen_error(s)
  s << "x"
  "mutable"
rescue FrozenError
  "FrozenError"
end

class Holder
  attr_reader :s
  def initialize(s) = (@s = s)
  def freeze_it = @s.freeze
end

# a name, an Array element and a Hash value, frozen through the local
s = +"abc"
t = s
a = [s]
h = { k: s }
s.freeze
p t.frozen?, a[0].frozen?, h[:k].frozen?, t.equal?(s)
p frozen_error(t), frozen_error(a[0]), frozen_error(h[:k])

# the answer is the String, frozen through another name's read too
s = +"def"
t = s
r = s.freeze
p r.equal?(t), t.frozen?, frozen_error(t)

# in an Array literal, a Hash literal and as a Hash key
s = +"ghi"
t = s
arr = [s.freeze]
hsh = { v: s.freeze }
key = +"key"
kt = key
hk = { key.freeze => 1 }
p arr[0].equal?(t), t.frozen?, hsh[:v].equal?(t), hk.keys[0].equal?(kt), kt.frozen?

# an instance variable and a global, through the reader and the name
o = Holder.new(+"iv")
before = o.s
o.freeze_it
p before.frozen?, o.s.frozen?, frozen_error(before)
$g = +"gl"
g2 = $g
$g.freeze
p g2.frozen?, frozen_error(g2)

# a block parameter and a Symbol to_proc
s = +"blk"
t = s
s.then { |x| x.freeze }
p t.frozen?
s = +"sym"
t = s
s.then(&:freeze)
p t.frozen?

# the frozen String's dup is a new, unfrozen one
s = +"dup"
t = s
d = s.freeze.dup
d << "!"
p d, t, t.frozen?, d.frozen?, d.equal?(t)

# an unfrozen name still changes before the freeze, and not after
s = +"seq"
t = s
t << "1"
s.freeze
p s, t, frozen_error(t)
