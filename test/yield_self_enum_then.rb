# A blockless yield_self answers an enumerator named `then`, as a blockless
# then does, as in CRuby.
e = 5.yield_self
p e
p 5.then
p e.size
p "s".yield_self.inspect == "s".then.inspect
p [1, 2].yield_self.to_a
