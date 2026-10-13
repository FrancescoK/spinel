# inject / reduce given their arguments through a splat: none, a seed, an
# operator, or a seed and an operator, known only at run time

def f(a, *args) = a.inject(*args)
p f([1, 2, 3], :+)
p f([1, 2, 3], 10, :*)
p((f([1, 2, 3]) rescue $!.message))
p((f([1, 2, 3], 1, :+, 3) rescue $!.message))

# with a block: a seed and an operator leave it unused
def g(a, *args) = a.inject(*args) { |x, y| x - y }
p g([1, 2, 3])
p g([1, 2, 3], 10)
p g([1, 2, 3], 10, :+)
p((g([1, 2, 3], 1, 2, 3) rescue $!.message))

def fwd(a, *args, &blk) = a.inject(*args, &blk)
p fwd([1, 2, 3]) { |x, y| x * y }
p fwd([1, 2, 3], 10) { |x, y| x * y }

# a Range, a Hash and an Array of Strings
def r(x, *args) = x.inject(*args)
p r(1..4, :*)
p r(1..4, 2, :*)
def h(x, *args) = x.inject(*args) { |acc, kv| acc + kv[1] }
p h({ a: 1, b: 2 }, 10)
def w(x, *args) = x.reduce(*args)
p w(%w[a b c], :+)
p w(%w[a b c], "z", :+)

# a splat beside a written argument, and an anonymous one
def mix(a, *args) = a.inject(1, *args)
p mix([1, 2, 3], :*)
def anon(a, *) = a.inject(*)
p anon([1, 2, 3], :+)
