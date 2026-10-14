# A store into a Hash nested in a parameter's Hash (`h[:attrs]["y"] = v`)
# widens the Hash literal the callers pass there, as a store through a
# local holding the outer literal does: a String key into the Symbol-keyed
# inner literal makes it the poly-keyed Hash.

def add(h)
  h[:attrs]["y"] = "2"
end
b = {attrs: {x: "1"}}
add(b)
p b

# two callers, each literal widened
def tag(opts)
  opts[:meta][1] = :one
end
d1 = {meta: {k: :v}}
d2 = {meta: {j: :w}}
tag(d1)
tag(d2)
p d1, d2
