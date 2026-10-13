# an Array, Hash or Range reopened with its own method of an iterator's
# name that does not yield takes a block-carrying call too: the block goes
# unused, or to a `&b` parameter, as in CRuby, and the call answers the
# reopen's value rather than the builtin loop's

class Array
  def each(*a) = a.size
  def map(*a, &b) = b ? b.call(a.size) : :no_block
end
class Hash
  def select(n) = [:hash_select, n]
end
class Range
  def select(*a) = [:range_select, a.size]
end

p [1].each(1, 2) { }
p [1].each { |x| x }
p [1, 2].map(5) { |n| n * 10 }
p [1, 2].map { |n| n * 10 }
p({1 => 2}.select(3) { |k, v| true })
p (1..2).select(1, 2) { }
p (1..2).select { |x| x }
