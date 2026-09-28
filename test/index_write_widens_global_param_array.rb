# An element write that the array's kind cannot hold widens the array to
# the general Array wherever the array lives: a global, a class variable, a
# constant, a parameter (and the caller's array behind it), not only a local
# or an ivar.

$g = [0, 0]
$g[1] = "z"
p $g

$q = [1]
$q << "s"
$q.push(:t)
p $q

TABLE = [1, 2]
TABLE[0] = "s"
p TABLE

class C
  @@a = [1, 2]
  def self.w; @@a[0] = "s"; @@a; end
  def self.add(x) = @@a << x
end
C.add(2.5)
p C.w

def m(arr); arr[0] = "q"; arr[1] = 3; arr; end
p m([0, 0])

def set_first(arr); arr[0] = "q"; arr; end
z = [0, 0]
set_first(z)
p z
$shared = [1, 2]
set_first($shared)
p $shared

def app(a); a << "s"; a.push(2.5); a; end
y = [1]
app(y)
p y

# an element read out of a method's fixed tuple stores that element's type
def pair = [1, "x"]
b = [0, 0, 0]
b[2] = pair[1]
p b
$t = [0, 0]
$t[0] = pair[-1]
p $t

class K
  def initialize; @a = [0, 0]; end
  def w; @a[1] = pair2[1]; @a; end
  def pair2 = [1, "x"]
end
p K.new.w

# a write the kind holds keeps the typed array
$n = [1, 2]
$n << 3
$n[0] = 7
p $n.sum
