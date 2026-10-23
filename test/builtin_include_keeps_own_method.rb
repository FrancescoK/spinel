# A module included into a builtin class comes after the class in its
# ancestors: the class's own method answers a name both have, and the
# module answers only the names the class lacks. A prepended module comes
# before it.
module Inc
  def size = 99
  def upcase = "M"
  def extra = :extra
end
class String
  include Inc
end
p "abc".size, "abc".upcase, "abc".extra
module ArrInc
  def first = :inc
  def second = self[1]
end
class Array
  include ArrInc
end
p [1, 2].first, [1, 2].second
module HashInc
  def keys = :k
end
class Hash
  include HashInc
end
p({ a: 1 }.keys)
module IntInc
  def abs = :abs
end
class Integer
  include IntInc
end
p(-3.abs)
module SymInc
  def to_s = "five"
end
class Symbol
  include SymInc
end
p :a.to_s
module Pre
  def length = 42
end
class String
  prepend Pre
end
p "abc".length
