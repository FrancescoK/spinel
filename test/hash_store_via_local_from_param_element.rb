# A store into a local that a method wrote from an element of its hash
# parameter (`r = block[:attrs].dup; r["y"] = v`) widens the hash literal
# the caller nested there, as a store straight into `block[:attrs]` does:
# the local's write was not followed to it, and the store raised the
# "typed as Symbol-keyed" TypeError at run time.

def eff(block)
  r = block[:attrs].dup
  r["y"] = "2"
  r
end

def fetched(block)
  r = block.fetch(:attrs)
  r["n"] = 3
  r
end

def same_kind(block)
  r = block[:opts]
  r[:z] = "3"
  r
end

def listed(block)
  r = block[:list].clone
  r << "s"
  r
end

p eff({type: :at, attrs: {x: "1"}})
b = {attrs: {x: "1"}}
p fetched(b), b
p same_kind({opts: {a: "1"}})
p listed({list: [1, 2]})
