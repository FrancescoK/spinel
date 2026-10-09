# Plain yielding builtin reopenings return the callable body's result.
# spinel: gc-minor
# spinel: share
class Array
  def twice = yield(size) * 2
end
class Hash
  def twice = yield(size) * 2
end
class String
  def twice = yield(size) * 2
end
class Integer
  def twice = yield(self + 1) * 2
end
p [1, 2].twice { |n| n + 1 }
p({a: 1}.twice { |n| n + 1 })
p "abc".twice { |n| n + 1 }
p 3.twice { |n| n + 1 }
block = proc { |n| n + 2 }
p [1, 2].twice(&block)
p({a: 1}.twice(&block))
p "abc".twice(&block)
p 3.twice(&block)
