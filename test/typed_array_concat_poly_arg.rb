# concat as a value on a typed array, given an array literal that holds a nil
# (a poly array): the value form had no arm for it and raised NoMethodError.
# The elements append through the boxed surface, a nil as the slot's nil.
p [2].concat([1, nil])
p ["s"].concat(["t", nil])
p [1.5].concat([nil, 2.5])
p [3].concat([4], [nil, 5])

def tail(n) = [n].concat([1, nil])
p tail(2)

def pick(n)
  n == 0 ? [1, nil] : [n].concat([1, nil])
end
p pick(0), pick(2)

# the recursive result reaches the concat too: its nil stays nil, not 0
def ints(n)
  n == 0 ? [1, nil] : [n].concat(ints(n - 1))
end
p ints(2)
p ints(2).include?(nil), ints(2).compact.sum
