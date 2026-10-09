# merge! and update given a Symbol-keyed Hash that is not written out at
# the call: a local, a parameter, a keyword rest, an instance variable, a
# method's value, one of two locals, a constant. A receiver whose keys are
# of another class takes the variant that holds both, as it does for
# `h.merge!({b: 2})`.

# written out at the call
s = {"a" => 1}
s.merge!({b: 2})
p s.to_a

# an empty receiver takes the argument's keys, and Symbol keys take more
m = {b: 2}
e = {}
e.merge!(m)
p e.to_a
y = {a: 1}
y.update(m)
p y.to_a

# a local
h = {"a" => 1}
h.merge!(m)
p h.to_a
p h["a"]
p h[:b]
p h.size
h.each { |k, v| p [k, v] }
p h.keys

# update, and an Integer-keyed receiver
i = {1 => "x"}
i.update(m)
p i.to_a
p i[1]
p i.keys

# String values, mixed values, Float keys
ss = {"a" => "x"}
ss.merge!(m)
p ss.to_a
sm = {"a" => 1, "c" => "x"}
sm.merge!(m)
p sm.values
f = {1.5 => 1}
f.merge!(m)
p f.to_a

# a parameter and a keyword rest
def from_param(o)
  h = {"a" => 1}
  h.merge!(o)
  h
end
p from_param({b: 2}).to_a

def from_kwrest(**o)
  h = {1 => 1}
  h.update(o)
  h
end
p from_kwrest(b: 2, c: 3).to_a

# an instance variable, a method's value, a constant, one of two locals
@iv = {c: 3}
a = {"a" => 1}
a.merge!(@iv)
p a.to_a

def made
  {d: 4}
end
b = {"a" => 1}
b.merge!(made)
p b.to_a

OPTS = {e: 5}
c = {"a" => 1}
c.merge!(OPTS)
p c.to_a

m2 = {z: 26}
d = {"a" => 1}
d.merge!(ARGV.empty? ? m : m2)
p d.to_a

# two arguments, and a block that no key calls
n = {c: 3}
t = {"a" => 1}
t.merge!(m, n)
p t.to_a
k = {"a" => 1}
k.merge!(m) { |key, old, new| old }
p k.to_a

# a second name sees the merge
g1 = {"a" => 1}
g2 = g1
g1.merge!(m)
p g2.to_a
p g2.equal?(g1)

# later uses: another merge, a delete, a store, a lookup's value
u = {"a" => 1}
u.merge!(m)
u.merge!(n)
u.delete(:b)
u["z"] = 9
p u.to_a
p u["a"] + u[:c]
p u.values.sum

# a global, a class variable and a top-level instance variable
$g = {"a" => 1}
$g.merge!(m)
p $g.to_a

class Keep
  @@h = {"a" => 1}
  def self.add(o)
    @@h.merge!(o)
  end
  def self.h = @@h
end
Keep.add(m)
p Keep.h.to_a

@top = {"a" => 1}
@top.merge!(m)
p @top.to_a

# a merge that is not reached
q = {"a" => 1}
q.merge!(m) if ARGV.size > 3
p q.to_a
p q["a"] + 1
