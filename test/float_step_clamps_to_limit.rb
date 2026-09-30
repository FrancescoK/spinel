# Float stepping yields i*step+begin and clamps an overshooting last value to the limit, as CRuby's ruby_float_step does.
p 0.1.step(0.3, 0.1).to_a
p 0.1.step(0.3, 0.1).size
p 0.1.step(by: 0.1, to: 0.3).to_a
a = []; 0.1.step(0.3, 0.1) { |f| a << f }; p a
a = []; 0.1.step(by: 0.1, to: 0.3) { |f| a << f }; p a
p 0.3.step(0.1, -0.1).to_a
a = []; 0.3.step(0.1, -0.1) { |f| a << f }; p a
p 1.0.step(2.0, 0.1).to_a.size, 1.0.step(2.0, 0.1).to_a.last
p 1.step(2, 0.5).to_a, 0.0.step(1.0, 0.1).to_a
x = [0.1, 1][0]; p x.step(0.3, 0.1).to_a

p (0.1..0.3).step(0.1).to_a, (0.1..0.3).step(0.1).size
p ((0.1..0.3) % 0.1).to_a
p (0.1...0.3).step(0.1).to_a
p (0.3..0.1).step(-0.1).to_a
r = (0.1..0.3)
p r.step(0.1).to_a, (r % 0.1).to_a
a = []; r.step(0.1) { |f| a << f }; p a
a = []; (0.1..0.3).step(0.1) { |f| a << f }; p a
def walk(r, s) = r.step(s).to_a
p walk(0.1..0.3, 0.1)

p 1.0.step(2.0, Float::INFINITY).to_a, 1.0.step(0.0, Float::INFINITY).to_a
a = []; 1.0.step(2.0, Float::INFINITY) { |f| a << f }; p a
p 1.0.step(Float::NAN, 0.5).to_a, 1.0.step(2.0, Float::NAN).to_a
p (0.0..1.0).step(Float::INFINITY).to_a, (0.0..1.0).step(Float::NAN).to_a
