# A proc whose local also holds another kind of value (here a Symbol) is
# called through a box. When its body stores an Integer key through its
# parameter, the Hash the call hands it widens, as for any other key, and
# the store matches CRuby. The Symbol-keyed Hash kept its kind, and the
# store raised TypeError at run time.

f = :none if ARGV.length == 9123
f = proc { |x| x.store(0, "v") }
h = {a: 1}
f.call(h)
p h

g = :none if ARGV.length == 9123
g = proc { |x| x[1] = "one" }
h2 = {"k" => 1}
g.call(h2)
p h2

l = :none if ARGV.length == 9123
l = lambda { |x| x[2] = :two }
h3 = {b: 2}
l.(h3)
p h3

def fw(f, x) = f.call(x)
k = :none if ARGV.length == 9123
k = proc { |x| x[0] = 5 }
h4 = {c: 3}
a4 = [1, 2]
fw(k, h4)
fw(k, a4)
p h4, a4

n = :none if ARGV.length == 9123
n = proc { |x| x[3] = 4 }
h5 = {1 => 2}
n.call(h5)
p h5
