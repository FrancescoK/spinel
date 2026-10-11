# A lazy chain held in a local runs the source it is made from once, where the
# local is written, as CRuby does: each force reads that source, and one made
# by a call, a variable read or a Range of computed ends is not made again at
# each force, nor first at the first one.

$log = []
def src(t)
  $log << t
  [1, 2, 3]
end
b = src(:a).lazy.map { |x| $log << :blk; x + 1 }
$log << :between
c = src(:c).lazy.select(&:odd?)
p $log
p b.to_a, c.to_a, b.first, b.first(2)
p $log

# a variable read: the Array it names when the chain is made
a = [1, 2, 3]
l = a.lazy.select(&:odd?)
a = [5, 6, 7]
p l.to_a
x = [3, 4]
m = (x + [5]).lazy.reject(&:even?)
x << 9
p m.to_a, m.first(1)

# a Range, a Hash and an Enumerator made by calls
$n = 0
def rng
  $n += 1
  1..4
end
r = rng.lazy.map { |i| i * 2 }
p $n, r.first(2), r.to_a, $n
def hsh
  $n += 1
  { a: 1, b: 2 }
end
h = hsh.lazy.map { |k, v| v }
p h.to_a, h.to_a, $n
def sl
  $n += 1
  [1, 2, 3].each_slice(2)
end
q = sl.lazy.map(&:sum)
p q.to_a, q.to_a, $n

# a Range literal's computed ends
k = 5
w = (1..k).lazy.map { |i| i + k }
k = 100
p w.to_a
$m = 0
def lo
  $m += 1
  2
end
v = (lo..6).lazy.select(&:even?)
p $m, v.to_a, v.first(1), $m
z = (lo..).lazy.map { |i| i * 2 }
p z.first(2), $m

# literals are left where they are
p (1..3).lazy.map { |i| i * i }.to_a
u = [4, 5].lazy.map { |i| -i }
p u.to_a, u.first

# a chain built on another local holding one
$log = []
ca = src(:ca).lazy
$log << :between
cb = ca.map { |x| x + 1 }
cc = cb.select(&:even?)
p $log
p cb.to_a, cc.to_a, cb.first, $log

# a builtin's view of a value: the value is made once, the view walks it
# when the chain is forced
$log = []
va = [1, 2, 3, 4]
vl = va.map { |x| $log << x; x }.each_slice(2).lazy.map(&:sum)
p vl.to_a, vl.to_a, $log
vb = [1, 2, 3, 4]
vm = vb.each_slice(2).lazy.map(&:sum)
vb = [9]
p vm.to_a
vc = [1, 2, 3]
vn = vc.each_with_index.lazy.map { |a, i| a * i }
vc << 4
p vn.to_a

# a local of the same name in another method is another local
def lf(arr)
  l = arr.each_slice(2).lazy.map(&:sum)
  arr << 100
  l.to_a
end
def lg(n)
  l = (1..n).lazy.map { |v| v * 2 }
  l.first(2)
end
def lh
  l = 5
  l * 2
end
p lf([1, 2, 3]), lg(5), lh
# a to_a written in the program is made where the chain is
th = {}
tl = th.to_a.lazy.map { |k, v| k }
th[:z] = 1
p tl.to_a

# a chain read inside a lambda or proc reads what the chain reads
def cf
  k = 3
  arr = [1, 2]
  l = arr.lazy.map { |x| x * k }
  pr = -> { l.to_a }
  k = 4
  p pr.call
  arr << 5
  p pr.call
  q = proc { |x| l.first(x) }
  p q.call(2)
end
cf
# a source rebound in a loop the chain's write is in
def wf
  a = [1, 2]
  i = 0
  while i < 2
    a = [i + 5] if i == 1
    l = a.lazy.map { |x| x * 10 } if i == 0
    i += 1
  end
  p l.to_a
end
wf
# a to_a written in a module's method
module LazyTo
  def go(s)
    l = s.chars.to_a.lazy.map { |c| c.upcase }
    s << "z"
    p l.to_a
  end
end
class LazyK
  include LazyTo
end
LazyK.new.go(+"ab")
