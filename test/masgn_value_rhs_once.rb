# A multiple assignment whose value is used evaluates its right-hand side
# once, whether it is one expression or a list of them.
$n = 0
def rhs = ($n += 1; [1, 2])
x = (a, b = rhs)
p x, a, b, $n

def f = ($n += 10; 5)
def g = ($n += 100; "s")
y = (c, d = f, g)
p y, c, d, $n

z = (e, *h = f, *rhs)
p z, e, h, $n

def nl = ($n += 1; nil)
v = (k, l = nl, 1)
p v, k, l, $n

def poly(q) = ($n += 1; q ? [1, "a"] : nil)
u = (m, n = poly(true))
p u, m, n, $n

p((o, r = rhs), $n)

def ret = (s, t = rhs)
p ret, $n

class P
  def initialize = (@c = 0)
  def val = (@c += 1; [@c, @c])
  def go = (@x, @y = val)
  attr_reader :c
end
pp = P.new
p pp.go, pp.c

# the targets' receivers and indexes still run before the values
$log = []
def k = ($log << :k; :a)
hh = {}
x2 = (hh[k], y2 = f, g)
p x2, hh, y2, $log
class O
  attr_accessor :v
end
$o = O.new
def obj = ($log << :obj; $o)
def idx = ($log << :idx; 1)
arr = [0, 0, 0]
$log = []
z2 = (obj.v, arr[idx] = f, g)
p z2, $o.v, arr, $log
$log = []
def rows = ($log << :rows; [[0, 0], [0, 0]])
w2 = (rows[0][1], q2 = f, g)
p w2, q2, $log
