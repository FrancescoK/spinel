# A split's Array held in a local, an element taken out with shift, and
# the rest mutated in place inside each: the block's own value carries the
# mutation, so each element binds as a copy (WEBrick's
# Cookie.parse_set_cookie).
def parse_set_cookie(str)
  elems = str.split(/;/)
  first = elems.shift
  first.strip!
  out = []
  elems.each { |pair|
    pair.strip!
    out << pair
  }
  [first, out, elems.size]
end
p parse_set_cookie("a=1; b=2 ;c=3")

# The same on a boxed receiver: str is a String or nil.
def parse_boxed(str)
  return [] unless str
  elems = str.split(/;/)
  out = []
  elems.each { |pair|
    pair.strip!
    k, v = pair.split(/=/, 2)
    out << [k, v]
  }
  out
end
h = { "c" => "x=1 ; y=2", "n" => nil }
p parse_boxed(h["c"])
p parse_boxed(h["n"])
