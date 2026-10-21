# A String stored into a Hash subclass's instance is that String: a change
# through a value read back reaches it, as CRuby's Hash keeps the object
# (#9258, which a share rule for subclasses of builtins had turned into a
# copy).
class Bag < Hash; end
s = +"abc"
b = Bag.new
b[:k] = s
r = b[:k]
r << "!"
p s, b

class Shelf < Hash
  def put(k, v) = (self[k] = v)
end
t = +"x"
sh = Shelf.new
sh.put(:a, t)
sh[:a] << "y"
p t
