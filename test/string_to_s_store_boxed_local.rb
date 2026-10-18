# A String's conversion stored into a container, from a local that nil
# reaches as well: the store converts, so the element is a copy of the
# caller's String, which the caller reads again. Refused, not appended to
# a copy.
def store(value)
  h = {}
  h["k"] = value.to_s
  h["k"] << "!" unless h["k"].frozen?
  h
end
v = +"abc"
p store(v), v
p store(nil)
