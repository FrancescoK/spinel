# A call that leaves out a defaulted argument, and runs while one version
# of the method is defined and again after a later def replaces it, gets
# the default of the version that runs: at the top level, in a class
# with a default that reads an earlier parameter, between versions of
# different arity, with a keyword default, through a splat and with a block.
def f(x = 1) = x
def via_f = [f, f(5)]
p via_f
def f(x = 2) = x * 10
p via_f

class Pair
  def pair(x = 1, y = x + 1) = [x, y]
  def both = [pair, pair(7)]
end
pr = Pair.new
p pr.both
class Pair
  def pair(x = 3, y = 4) = [x, y, 0]
end
p pr.both

def grow(a) = [a]
def via_grow = grow(1)
p via_grow
def grow(a, b = 5) = [a, b]
p via_grow

def kw(k: 1) = k
def via_kw = [kw, kw(k: 9)]
p via_kw
def kw(k: 2) = k * 10
p via_kw

def sp(x = 1, y = 2) = [x, y]
def via_sp(*a) = sp(*a)
p via_sp, via_sp(8)
def sp(x = 3, y = 4) = [y, x]
p via_sp, via_sp(8)

def each_n(n = 2) = n.times { |i| yield i }
def sum_n
  t = 0
  each_n { |i| t += i + 1 }
  t
end
p sum_n
def each_n(n = 3) = n.times { |i| yield i * 10 }
p sum_n

# a program method whose name the second entry's C name would take
def h(x = 1) = x
def h__entry1(y) = y + 1000
def via_h = [h, h(5), h__entry1(1)]
p via_h
def h(x = 2) = x * 10
p via_h
