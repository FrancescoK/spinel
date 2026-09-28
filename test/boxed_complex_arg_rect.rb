# arg, angle, phase, rect and rectangular on a number read out of a
# container answer as on a typed one: a Complex its angle and [real, imag],
# a real number 0 (pi when negative) and [self, 0].
c = [Complex(3, 4), 0][0]
p [c.arg, c.angle, c.phase]
p [c.rect, c.rectangular]
p [Complex(3, -4.5), 0][0].rect
p [Complex(-1, 0), 0][0].angle
nums = [5, -5, 2.5, -2.5, Rational(1, 2), Rational(-1, 2), 2**70, -(2**70),
        Rational(-(2**70), 3), Complex(0, 2)]
p nums.map { |x| x.phase }
p nums.map { |x| x.rectangular }
re, im = c.rect
p re + im
# a class of the program's own with a reader of the name keeps it, and a
# number beside it in the same slot still answers
class Tri
  attr_reader :angle
  def initialize(a) = @angle = a
end
p [Tri.new(90), Complex(0, 1), -3].map { |x| x.angle }
acc = []
300.times { |i| acc << [Rational(i, 7), "s"][0].rect }
p [acc.size, acc[299]]
p (["x", 0][0].arg rescue $!.message)
p ([nil, 0][0].rect rescue $!.message)
