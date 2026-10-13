# union / difference / intersection given their operands through a splat:
# how many there are is known only at run time

def u(a, *args) = a.union(*args)
def d(a, *args) = a.difference(*args)
def i(a, *args) = a.intersection(*args)
def ub(a, *args, &blk) = a.union(*args, &blk)

p u([1, 2, 3], [4], [1, 5])
p d([1, 2, 3], [2], [3])
p i([1, 2, 3], [2, 3], [3])
p ub([1, 2, 3], [4])

# no operand at all: the receiver's copy, deduplicated by union alone
r = [1, 1, 2]
p u(r), d(r), i(r)
p u(r).equal?(r), d(r).equal?(r), i(r).equal?(r)

# a receiver of another kind, and one whose type is not known statically
p u(["a", "a"], ["b"])
p d([1, 2, 3], ["x"], [3])
p i([:a, :b], [:b])

# a splat among other operands
xs = [[3], [4]]
p [1, 2].union([2], *xs, [5])

# an operand that is no Array, and a receiver that is no Array
begin
  u([1], 2)
rescue TypeError => e
  p e.message
end
begin
  u(nil, [1])
rescue NoMethodError => e
  p e.message
end
