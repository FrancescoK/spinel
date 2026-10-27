# A global read before its first write is nil, also when the read is in an
# #each that the program reaches through an Enumerable method or an
# Enumerator. Such a call is rewritten to a helper the compiler makes
# (`obj.map { }` reads `obj.__enum_to_a.map { }`, `obj.to_enum(:each)`
# calls `__to_enum_each`), and a call of the helper runs the program's
# #each. Whether something can read the global first is asked of the
# calls of the load phase by the names the program defines methods by,
# and the helpers, made after those names were taken, were not among
# them: the global counted as written first, its slot took no nil, and
# the read printed 0.0.

class Bag
  include Enumerable
  def each
    yield $bag.inspect
  end
end
p Bag.new.map { |x| x }
p Bag.new.to_a
p Bag.new.first
$bag = 1.5
p Bag.new.to_a

class Feed
  def each
    yield $feed.inspect
  end
end
e = Feed.new.to_enum(:each)
p e.next
$feed = 2.5
p Feed.new.to_enum(:each).next
