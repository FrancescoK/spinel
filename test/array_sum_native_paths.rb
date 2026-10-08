# spinel: int64
# spinel: share
# spinel: gc-minor
# Native sums preserve the empty seed, full-width integers, and Float consumers.
def show_native_sum
  r = yield
  p r
end
m = -(2**62) - 2**62
show_native_sum { [m].sum }
show_native_sum { [m, 5].sum }
show_native_sum { [m, 5].sum(1) }
show_native_sum { [m, 5].sum(0.5) }
show_native_sum { [m].sum { |x| x } }
show_native_sum { [m, 5].inject(:+) }
p [m].sum
p [m].sum { |x| x }
a = [0.5, 1.25]
e = a.take(0)
p [a.sum.class, e.sum.class]
p [a.sum { |x| x * 2.0 }, e.sum { |x| x * 2.0 }]
p [a.sum(3) { |x| x }, e.sum(3) { |x| x }]
t = 0.0
3.times { t += a.sum; t += e.sum }
p [t, t.class]
a.clear
t += a.sum
p [t, t.class]
seed_calls = 0
p e.sum(begin; seed_calls += 1; 7; end) { |x| x }
p seed_calls
# A boxed receiver keeps the typed array's element-nil fact.
missing = [1][ARGV.size + 9]
maybe = [nil, true][ARGV.size]
boxed = maybe || [missing, 3]
begin
  p boxed.sum
rescue TypeError => ex
  p ex.class
end
boxed_min = maybe || [m, 5]
p boxed_min.sum
