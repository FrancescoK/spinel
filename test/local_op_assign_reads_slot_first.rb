x = 1.5
x += (x = 100.0; 2.25)
p x
f = 8.0
f -= (f = 1.0; 0.5)
p f
g = 3.0
g *= (g = 10.0; 2.0)
p g
h = 9.0
h /= (h = 1.0; 3.0)
p h
i = 10
i += (i = 100; 5)
p i
k = 3
k *= (k = 100; 4)
p k
b = 1
b <<= (b = 100; 2)
p b
s = "a"
s += (s = "zzz"; "b")
p s
r = 1r
r += (r = 10r; 2)
p r
cx = Complex(1, 1)
cx += (cx = Complex(5, 5); Complex(0, 1))
p cx
pv = 1
pv = 2.5 if ARGV.size > 99
pv += (pv = 100; 1)
p pv
bg = 2**70
bg += (bg = 1; 1)
p bg
q = 1.0
q += (q, _ = 50.0, 0; 1.0)
p q
w = 1.0
w += [1, 2].sum { |e| w = 100.0; e.to_f }
p w
n = 1.0
lam = -> { n = 500.0; 1.0 }
n += lam.call
p n
y = 1.5
v = (y += (y = 20.0; 3.0))
p v, y
def m
  z = 2.0
  z += (z = 7.0; 1.0)
end
p m
t = 0.0
3.times { |j| t += (t = 0.0; j.to_f) }
p t

class Acc
  def initialize; @x = 1; @f = 1.5; end
  def bump; @x = 1000; 5; end
  def run
    @x += bump
    @f += (@f = 9.0; 1.0)
    p @x, @f
  end
end
Acc.new.run
