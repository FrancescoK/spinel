# `range.step(n) { }` answers the range. As a block's last expression the
# loop left the spliced block with no value, and the C read a void
# expression; Integer and Float ranges alike. The receiver is evaluated
# once.

def t
  x = yield
  p x
end
t { (1..9).step(3) { |v| } }
t { (1.5..3.0).step(0.5) { |v| } }
r = (2..8)
t { r.step(2) { |v| } }
def m(q) = q.step(2) { |v| }
p m(1..5)
y = [1, 2].map { |k| (k..4).step(1) { |v| } }
p y
$n = 0
def mk = ($n += 1; 1..3)
t { mk.step(1) { |v| } }
p $n
z = 0
t { (1.0..2.0).step(0.5) { |v| z += 1 } }
p z
