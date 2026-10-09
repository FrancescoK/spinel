# An alias that captured Array's method in an Array subclass, called on a
# receiver: the alias resolves by name to the class's own `size`, which would
# run instead of Array's, so it is refused until the alias is a method of its
# own. Inside the class, without a receiver or on self, it is Array's.
# spinel: reject-subclass: calling `raw_size`, an alias of Array#size in Log, on a receiver is not supported yet
class Log < Array
  alias_method :raw_size, :size
  def size = raw_size * 10
end
l = Log.new([1, 2])
p l.raw_size
