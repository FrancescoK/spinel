# an iterator name the program gives Array, Hash or Range itself takes the
# arguments its own definition says: a splat handed to it without a block
# reaches that method, not the builtin's "expected 0" check

class Array
  def each(*a) = a.size
end
class Hash
  def map(*a) = [:hash_map, a.size]
end
class Range
  def select(*a) = [:range_select, a.size]
end
args = [1, 2]
p [1].each(*args)
p({1 => 2}.map(*args))
p (1..2).select(*args)
p [1].each(*[])
