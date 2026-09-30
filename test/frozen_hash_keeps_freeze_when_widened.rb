# A Hash frozen as a literal stays frozen when a store widens the variable to
# the general Hash representation: the store is refused and the Hash is
# unchanged.
def refused(h)
  yield
  :no_error
rescue FrozenError => e
  [e.class, e.receiver.equal?(h)]
end

h = {}.freeze
p h.frozen?
p refused(h) { h[1] = 1 }
p refused(h) { h[:a] = 1 }
p refused(h) { h["a"] = 1 }
p h, h.size

# a store that decides the kind of an empty literal without a widening
h2 = {}.freeze
p refused(h2) { h2[:a] = "x" }
p h2.frozen?

EMPTY = {}.freeze
p EMPTY.frozen?
p refused(EMPTY) { EMPTY[:k] = 1 }
p EMPTY

# a literal with pairs, widened by a store of another kind
s1 = {"a" => 1}.freeze
p refused(s1) { s1["z"] = "s" }
p s1.frozen?, s1.size
s2 = {"a" => "x"}.freeze
p refused(s2) { s2["z"] = 1 }
p s2.frozen?, s2.size
s3 = {a: 1}.freeze
p refused(s3) { s3["z"] = :sy }
p s3.frozen?, s3.size

# a Hash that is not frozen widens as before
u = {}
u[1] = 1
u[:a] = "x"
p u, u.frozen?
v = {"k" => 1}
v["j"] = "s"
p v

# a copy of a frozen Hash is not frozen
w = {}.freeze
d = w.dup
d[1] = 2
p d, d.frozen?, w.frozen?
