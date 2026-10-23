# A Hash reopen that defines a name the Hash reduce fold takes with a block
# (count, sum): the call with a block reaches the reopen, which the block is
# handed to, rather than the builtin's loop. The inference types the call by
# the reopen; under --int-overflow=promote the two disagreed and the C did
# not build.
class Hash
  def count
    block_given? ? keys.map { |k| yield k }.size : -1
  end
  def sum
    block_given? ? values.map { |v| yield v }.size * 100 : 0
  end
end
h = { a: 1, b: 2 }
p h.count { |k| nil }
p h.count
p h.sum { |v| v }
p h.sum
