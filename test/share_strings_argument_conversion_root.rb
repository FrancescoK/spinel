# A shared String argument made from a literal or bare read must stay
# rooted while a sibling rest argument allocates its array.
# spinel: gc-minor
def append_suffix(a, *items, suffix:)
  p a
  items.each { |s| s << suffix; p s }
end

a = +"a"
s = +"s"
items = [+"t"]
append_suffix(a, s, *items, suffix: "!")

Suffix = "?"
s = +"s"
items = [+"t"]
append_suffix(a, s, *items, suffix: Suffix)

suffix = "."
s = +"s"
items = [+"t"]
append_suffix(a, s, *items, suffix: suffix)

s = +"s"
items = [+"t"]
append_suffix(a, s, *items, suffix: "\0z")

s = +"s"
items = [+"t"]
append_suffix(a, s, *items, suffix: +"m")
