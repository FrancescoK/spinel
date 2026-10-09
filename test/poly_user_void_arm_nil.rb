# A user method that answers nil, reached through a poly receiver that may
# also be a Hash, answers nil: the dispatch's result started as Hash#fetch's
# default, and the user arm left it in place (#8200).
class Store
  def fetch(key, default) = nil
  def update(k, v) = nil
end

def pick(i) = i > 0 ? Store.new : { "a" => 1 }

p pick(1).fetch("k", "x")
p pick(0).fetch("k", "x")
p pick(0).fetch("a", "x")
p pick(1).update("k", 2)
