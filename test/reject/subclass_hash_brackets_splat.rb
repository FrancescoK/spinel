# X[*args] of a Hash subclass: whether the list is one Hash, pairs, or keys
# and values is known only at run time.
class Registry < Hash
end
def make(*args) = Registry[*args]
p make(:a, 1, :b, 2)
p make({c: 3})
