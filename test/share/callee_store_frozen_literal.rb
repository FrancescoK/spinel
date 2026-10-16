# A frozen literal a method stores into the container its caller passed
# is its own handle: the caller's container holds the literal itself,
# frozen, beside the Strings it shares with another name.
def get(parts)
  params = {}
  params["id"] = parts[1]
  params
end
def fill(h)
  h["x"] = "y" if h
end
parts = ["a", +"7"]
c = get(parts)
fill(c)
parts[1] << "0"
p c, c["x"].frozen?
begin
  c["x"] << "!"
rescue FrozenError => e
  p e.class
end
p c
