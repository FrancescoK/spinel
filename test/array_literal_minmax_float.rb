# spinel: int64 -- assumes a 64-bit Integer (values or arithmetic past 2^31); not run on a 32-bit target
# `[a, b].min` / `.max` on a literal of Floats is the extreme of the
# values, compared in place with no array built, and it is a Float, not
# a Float that may be nil. Each element still runs once, in order.
$log = []
def v(x)
  $log << x
  x
end

p [v(3.5), v(1.5), v(2.5)].min, $log
$log.clear
p [v(3.5), v(1.5), v(2.5)].max, $log
p [5.5].min, [5.5].max
p [-1.5, -1.5, 0.5].min, [7.5, 7.5, 2.5].max

# The first of equal values wins, as in CRuby: 0.0 == -0.0.
p [0.0, -0.0].max, [-0.0, 0.0].max, [0.0, -0.0].min, [-0.0, 0.0].min
# The same with a -0.0 that is known only when the program runs.
nz = -(ARGV.size.to_f)
p [0.0, nz].min, [nz, 0.0].max, [0.0, 2.0, nz, 1.5].min, [nz, -2.0, 0.0].max

# A NaN cannot be compared, as in CRuby. One element needs no comparison.
nan = 0.0 / 0.0
p [nan].max, [nan].min
def nan_cmp
  yield
rescue ArgumentError => e
  e.class
end
p nan_cmp { [nan, 1.0].max }, nan_cmp { [1.0, nan].max }
p nan_cmp { [nan, 1.0].min }, nan_cmp { [1.0, 2.0, nan].min }
# The message names the extreme so far, as in CRuby.
def nan_msg
  yield
rescue ArgumentError => e
  e.message
end
p nan_msg { [1.0, 2.0, nan].max }, nan_msg { [nan, 1.0].min }

# A local that takes the extreme of itself and a Float stays a Float.
def box_distance2(x0, z0, x1, z1, ex, ez)
  dx = ((x0 + x1) * 0.5 - ex).abs - (x1 - x0) * 0.5
  dz = ((z0 + z1) * 0.5 - ez).abs - (z1 - z0) * 0.5
  dx = [dx, 0.0].max
  dz = [dz, 0.0].max
  dx * dx + dz * dz
end
p box_distance2(0.0, 0.0, 16.0, 16.0, 8.0, 8.0)
p box_distance2(0.0, 0.0, 16.0, 16.0, 20.0, -3.0)

# An instance variable that takes the extreme of itself and a constant.
class Air
  MAX = 300.0
  attr_reader :air
  def initialize = (@air = 0.0)
  def refill(dt) = (@air = [@air + dt * 20.0, MAX].min)
  def spend(n) = (@air = [@air - n, 0.0].max)
end
air = Air.new
3.times { air.refill(4.0) }
p air.air
air.spend(500.0)
p air.air
20.times { air.refill(1.0) }
p air.air

s = 0.0
1000.times { |i| s += [i * 0.5, 100.0].min + [i * -0.25, -50.0].max }
p s

# An Integer parameter or instance variable that takes the extreme of
# itself and an Integer stays an Integer too.
def floor_at_zero(n, k)
  n = [n - k, 0].max
  n * 2
end
p floor_at_zero(5, 3), floor_at_zero(1, 3)
class Count
  attr_reader :n
  def initialize = (@n = 0)
  def add(k) = (@n = [@n + k, 10].min)
end
count = Count.new
count.add(4)
p count.n
count.add(9)
p count.n

# A literal of Integers and Floats keeps the value of the winner.
p [1, 2.5].max, [3, 2.5].max, [1, 2.5].min, [3, 2.5].min

# An element that may be nil keeps the Array path.
x = [1.5, nil][ARGV.size]
begin
  p [x, 2.5].min
rescue ArgumentError, NoMethodError => e
  p e.class
end
y = [nil, 1.5][ARGV.size]
begin
  p [y, 2.5].min
rescue ArgumentError, NoMethodError => e
  p e.class
end

# Long literals with signed zeros, Infinity and values only known at run time.
def outcome
  yield
rescue => e
  "#{e.class}: #{e.message}"
end
def same_f(v)
  v
end
def same_i(v)
  v
end
fx = -0.0
inf = 1.0 / 0.0
ix = -3
p outcome { v = [2**40, 0, same_i(4), 7, 3, 2**40, 3].min; [v.inspect, v.class.name] }
x5 = [100.0, 1e20, inf, 1e20, 100.0, inf, 1e-5].min; p x5 rescue p $!
p outcome { v = [0.0, 1e-5, 2.0, fx.abs, same_f(0.5), -inf, 0.0, -2.25].max; [v.inspect, v.class.name] }
p outcome { v = [0.0, 1e-5, 2.0, fx.abs, same_f(0.5), -inf, 0.0, -2.25].max; v.nil? ? 0 : v * 2 }
x6 = [ix * -1, same_i(-4), 2**40, same_i(-4)].max; p x6 rescue p $!
p outcome { v = [ix * -1, 3, same_i(-4), 7].min; [v.inspect, v.class.name] }
x7 = [-2].max; p x7 rescue p $!
p outcome { v = [2.0, (fx * 2), 1e20].max; [v.inspect, v.class.name] }
p outcome { v = [2.0, (fx * 2), 1e20].max; v.nil? ? 0 : v * 2 }
x8 = [100.0, same_f(-0.0), 2.0].min; p x8 rescue p $!
x9 = [1e20, 1e-5, -0.0, 1.5, 1e-5, fx.abs, 100.0].min; p x9 rescue p $!
p outcome { v = [-inf, same_f(0.5), fx, 0.0, same_f(-0.0), (fx * 2)].min; [v.inspect, v.class.name] }
p outcome { v = [-inf, same_f(0.5), fx, 0.0, same_f(-0.0), (fx * 2)].min; v.nil? ? 0 : v * 2 }
x10 = [0.0, 1e20, 1e20, 1e20, 2.0, same_f(-0.0), fx, 1.5].min; p x10 rescue p $!
x11 = [3, ix, same_i(4), ix * -1].max; p x11 rescue p $!
x12 = [-2.25, fx, -inf].min; p x12 rescue p $!
p outcome { v = [7, 2**40, same_i(4), 2**40, 0, same_i(4)].max; [v.inspect, v.class.name] }
x13 = [2**40, 7].max; p x13 rescue p $!
