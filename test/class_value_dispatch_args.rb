# A class method called on a Class value held in a variable, where every
# class defining it can take the call (`o = cond ? A : B; o.w(...)`), is a
# switch with one arm per class. Each arm bound the arguments by hand, one
# argument to one parameter, out of a table of 16: an argument past the 16th
# was dropped without running, a post after a rest read an argument the rest
# had taken, and a splat or a keyword hash reached a positional slot whole.
# Each arm now binds them as a direct call to its method does. A Class in a
# boxed value took each argument once already, but only 64 of them: past
# that, the rest ran after a `*` or `**` operand written after them.
# spinel: gc-minor
$log = []
def lg(x) = ($log << x; x)

class A
  def self.w(*r) = r.size
  def self.f(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18) = [a1, a17, a18]
  def self.d(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17 = :d17, a18 = :d18) = [a16, a17, a18]
  def self.g(a, *r, z) = [a, r, z]
  def self.k(a, k: 1, **o) = [a, k, o]
  def self.s(a, b = 2) = [a, b]
  def self.m(a) = [:a, a]
  def self.z = :az
end
class B
  def self.w(*r) = r.size + 100
  def self.f(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18) = [a1, a18, a17]
  def self.d(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17 = :e17, a18 = :e18) = [a18, a17, a16]
  def self.g(a, *r, z) = [z, r, a]
  def self.k(a, k: 2, **o) = [k, a, o]
  def self.s(a, b = 3) = [b, a]
  def self.m(a, b) = [:b, a, b]
  def self.z = :bz
end

def run(o)
  # past 16 arguments, each runs once, in order
  $log = []
  p o.w(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18)
  p o.w(lg(1), lg(2), lg(3), lg(4), lg(5), lg(6), lg(7), lg(8), lg(9), lg(10), lg(11), lg(12), lg(13), lg(14), lg(15), lg(16), lg(17), lg(18), lg(19), lg(20)), $log
  $log = []
  p o.w(lg(1), lg(2), lg(3), lg(4), lg(5), lg(6), lg(7), lg(8), lg(9), lg(10), lg(11), lg(12), lg(13), lg(14), lg(15), lg(16), lg(17), lg(18), lg(19), lg(20), lg(21), lg(22), lg(23), lg(24), lg(25), lg(26), lg(27), lg(28), lg(29), lg(30), lg(31), lg(32), lg(33), lg(34), lg(35), lg(36), lg(37), lg(38), lg(39), lg(40), lg(41), lg(42), lg(43), lg(44), lg(45), lg(46), lg(47), lg(48), lg(49), lg(50), lg(51), lg(52), lg(53), lg(54), lg(55), lg(56), lg(57), lg(58), lg(59), lg(60), lg(61), lg(62), lg(63), lg(64), lg(65), lg(66), lg(67), lg(68), lg(69), lg(70)), $log.size
  p o.f(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18)
  p o.d(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)
  # a post after a rest
  p o.g(1, 2, 3, 4)
  # splats and keywords
  x = [1, 2, 3]
  p o.w(*x), o.w(0, *x, 4)
  p o.s(*[5, 6]), o.s(*[7])
  p o.k(1), o.k(1, k: 5), o.k(1, j: 6, k: 7)
  h = {k: 8, m: 9}
  p o.k(2, **h)
  $log = []
  p o.w(*[lg(1)], lg(2)), $log
  # the count, judged per class
  begin; p o.s(*[1, 2, 3]); rescue ArgumentError => e; p e.message; end
  begin; p o.m(1); rescue ArgumentError => e; p e.message; end
  begin; p o.m(*[1, 2]); rescue ArgumentError => e; p e.message; end
  # each splat may spread to nothing: two of them still reach a method of none
  e = []
  p o.z(*[], *[])
  p o.z(*e, *e)
  begin; p o.m(*e, *[1, 2]); rescue ArgumentError => e2; p e2.message; end
  # arguments that allocate, held while the ones after them allocate
  3.times do |i|
    p o.f("s#{i}-1", "s#{i}-2", "s#{i}-3", "s#{i}-4", "s#{i}-5", "s#{i}-6", "s#{i}-7", "s#{i}-8", "s#{i}-9", "s#{i}-10", "s#{i}-11", "s#{i}-12", "s#{i}-13", "s#{i}-14", "s#{i}-15", "s#{i}-16", "s#{i}-17", "s#{i}-18")
    p o.f(*(1..18).map { |j| "t#{i}-#{j}" })
  end
end
run(A)
run(B)

c = ARGV.size == 0 ? A : B
p c.w(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18)
p c.public_send(:w, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18), c.send(:w, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18)
$log = []
p [lg(0), c.w(lg(1), lg(2))], $log

def lh = ($log << :h; {k: 1})
v = [A, B, 1][0]
$log = []
p v.w(lg(1), lg(2), lg(3), lg(4), lg(5), lg(6), lg(7), lg(8), lg(9), lg(10), lg(11), lg(12), lg(13), lg(14), lg(15), lg(16), lg(17), lg(18), lg(19), lg(20), lg(21), lg(22), lg(23), lg(24), lg(25), lg(26), lg(27), lg(28), lg(29), lg(30), lg(31), lg(32), lg(33), lg(34), lg(35), lg(36), lg(37), lg(38), lg(39), lg(40), lg(41), lg(42), lg(43), lg(44), lg(45), lg(46), lg(47), lg(48), lg(49), lg(50), lg(51), lg(52), lg(53), lg(54), lg(55), lg(56), lg(57), lg(58), lg(59), lg(60), lg(61), lg(62), lg(63), lg(64), lg(65), lg(66), lg(67), lg(68), lg(69), lg(70), **lh), $log.size, $log.last
$log = []
p v.w(lg(1), lg(2), lg(3), lg(4), lg(5), lg(6), lg(7), lg(8), lg(9), lg(10), lg(11), lg(12), lg(13), lg(14), lg(15), lg(16), lg(17), lg(18), lg(19), lg(20), lg(21), lg(22), lg(23), lg(24), lg(25), lg(26), lg(27), lg(28), lg(29), lg(30), lg(31), lg(32), lg(33), lg(34), lg(35), lg(36), lg(37), lg(38), lg(39), lg(40), lg(41), lg(42), lg(43), lg(44), lg(45), lg(46), lg(47), lg(48), lg(49), lg(50), lg(51), lg(52), lg(53), lg(54), lg(55), lg(56), lg(57), lg(58), lg(59), lg(60), lg(61), lg(62), lg(63), lg(64), lg(65), lg(66), lg(67), lg(68), lg(69), lg(70), *[lg(0)]), $log.index(0)
$log = []
p c.w(lg(1), lg(2), lg(3), lg(4), lg(5), lg(6), lg(7), lg(8), lg(9), lg(10), lg(11), lg(12), lg(13), lg(14), lg(15), lg(16), lg(17), lg(18), lg(19), lg(20), lg(21), lg(22), lg(23), lg(24), lg(25), lg(26), lg(27), lg(28), lg(29), lg(30), lg(31), lg(32), lg(33), lg(34), lg(35), lg(36), lg(37), lg(38), lg(39), lg(40), lg(41), lg(42), lg(43), lg(44), lg(45), lg(46), lg(47), lg(48), lg(49), lg(50), lg(51), lg(52), lg(53), lg(54), lg(55), lg(56), lg(57), lg(58), lg(59), lg(60), lg(61), lg(62), lg(63), lg(64), lg(65), lg(66), lg(67), lg(68), lg(69), lg(70), **lh), $log.size, $log.last
