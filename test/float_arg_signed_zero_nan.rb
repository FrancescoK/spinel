# Float#arg (and its aliases angle and phase) answers as CRuby's float_arg:
# a NaN is its own angle, a Float with its sign bit set is pi (so -0.0 is
# pi, not 0), and every other Float is the Integer 0. The rows tested
# `x < 0`, which answered 0 for -0.0 and the Integer 0 for a NaN, so a
# later `.nan?` raised NoMethodError. Float#polar carries the same angle.
# The probes cover a Float literal and local, a nilable Float slot (a
# sentinel), and a Float read out of a mixed Array (a boxed value).

p (-0.0).angle, (-0.0).arg, (-0.0).phase, 0.0.angle, (-1.5).arg, 2.5.phase
n = Float::NAN
p n.angle.nan?, n.arg.nan?, n.phase.nan?, n.angle.class
p (-0.0).polar, n.polar.map(&:nan?)
z = -0.0
p z.angle, z.arg.class, z.phase

# a nilable Float slot
def pick(i, v) = i > 0 ? v : nil
m = pick(ARGV.size + 1, -0.0)
p m.angle unless m.nil?
k = pick(ARGV.size + 1, Float::NAN)
p k.arg.nan? unless k.nil?
p k.polar.map(&:nan?) if k

# a boxed receiver
a = [-0.0, 1, "s", Float::NAN, -3, 0.0]
p a[0].angle, a[0].arg, a[0].phase, a[3].angle.nan?, a[4].arg, a[5].phase
p a[0].polar, a[3].polar.map(&:nan?)
a.first(2).each { |v| p v.angle }
