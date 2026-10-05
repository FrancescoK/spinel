# The value of `p(*v)`: how many arguments a splat gives is known at run
# time. None answers nil and prints nothing, one prints and answers that
# argument, more print each and answer the array. An Array splatted from a
# variable was taken as one argument: `one = [8]; x = p(*one)` printed [8]
# and left an address in x.
a = [1, 2]
y = p(*a)
p y
one = [8]
z = p(*one)
p z
none = [1].select { |q| q > 5 }
n = p(*none)
p n
w = 5
x = p(*w)
p x
r = 3..4
x = p(*r)
p x
x = p(*nil)
p x

# beside other arguments
x = p(0, *a)
p x
x = p(*a, 3)
p x
x = p(0, *none)
p x
x = p(*none, *none)
p x
x = p(*a, *r)
p x

# as the last expression of a method, the value a caller reads
def last(v) = p(*v)
p last([8]), last([8, 9]), last(5), last("t"), last(nil), last([]), last(3..4)
def two(v) = p(1, *v)
p two([8]), two(5), two(nil), two([])

# pp is the same call
x = pp(*one)
p x
x = pp(*a)
p x

# the value in use: an argument, a receiver, a condition
def twice(q) = [q, q]
p twice(p(*one))
p p(*a).size
puts "seen" if p(*one)
puts "none" unless p(*none)

# without a splat nothing changes
x = p(7)
p x
x = p(7, 8)
p x
x = p(a)
p x
