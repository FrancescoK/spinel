# A store into a Hash read out of an Array (`scopes.last[name] = info`),
# with a key no literal names, typed an unrelated Struct field: the class
# facts made the element read answer the Array itself, so the store went
# into the Array and the read came back with the stored value's class, and
# the Struct `[]=` rule widened every Struct's nil member through a box it
# could not bound. `n.info ||= {}` was then refused (#10016).
Node = Struct.new(:info, :ty)
Info = Struct.new(:line)
Pair = Struct.new(:a, :b)

def declare(scopes, name, info)
  scopes.last[name] = info
end

def declare_at(scopes, name, info)
  scopes[-1][name] = info
end

def set(o, k, v)
  o[k] = v
end

scopes = [{}]
declare(scopes, "x", Info.new(1))
declare_at(scopes, "y", Info.new(2))
p scopes.last.keys
p scopes.first["x"].line

n = Node.new
n.info ||= {}
n.ty ||= :int
p n.info, n.ty

# a box that really holds a Struct, with a key no literal names
pr = Pair.new(1, 2)
h = {}
[pr, h].each_with_index { |o, i| set(o, i.zero? ? :a : "z", 10 + i) }
p pr, h
k = [:a, :b].last
set([pr, h].first, k, "s")
p pr.b

# a run of elements is a container of its own
rows = [[Info.new(3)], [Info.new(4)]]
p rows.last(1)[0][0].line
p rows.first(2).size
hh = { a: Info.new(5) }
p hh.first[1].line
p hh.min_by { |kk, _| kk }[1].line
p hh.shift[1].line
