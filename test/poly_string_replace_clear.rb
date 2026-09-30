# String#replace and String#clear on a String held in a poly slot (a
# parameter another caller hands an Array, an ivar holding either) change
# the String: a plain string box cannot be changed in place, so the local or
# ivar takes the new String back, as `insert` does. A frozen String raises
# FrozenError and a source that is no String raises TypeError, as the typed
# calls do. Both answered the box untouched: `s.replace("r")` left s as it
# was, and `s.clear` too.

class Holder
  def initialize(v) = @v = v
  def swap(x) = (@v.replace(x); @v)
  def wipe = (@v.clear; @v)
end
p Holder.new([1]).swap([2])
p Holder.new(+"ab").swap("cd")
p Holder.new({a: 1}).wipe
p Holder.new(+"ab").wipe

def rep(s, x) = (s.replace(x); s)
def clr(s) = (s.clear; s << "n"; s)
def rep_value(s, x) = s.replace(x)
p rep([1], [3]), rep(+"q", "r"), rep(+"q", +"long" * 20)
p clr([1]), clr(+"zz"), clr({k: 1}.keys)
p rep_value(+"a", "b"), rep_value([0], [9])

def try
  p yield
rescue TypeError, FrozenError => e
  puts "#{e.class}: #{e.message}"
end
try { rep(+"q", 5) }
try { rep("fr".freeze, "x") }
try { clr("fz".freeze) }
