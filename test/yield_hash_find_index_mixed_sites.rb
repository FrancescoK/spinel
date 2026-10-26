# find_index on a yield with an Array block and a Hash block answers an index
# or nil per site, not the element's kind: the Hash site's Integer beside the
# Array site's nil must not be read through the Array site's slot.
def fi = yield.find_index([:a, 1])

p fi { [1, 2] }
p fi { { a: 1 } }
p fi { [[:a, 1]] }
