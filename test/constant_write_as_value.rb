# A constant assignment is an expression whose value is the assigned value:
# an argument (ruby-bench's blurhash does `make_shareable(ARRAY = ...)`), an
# operand, another assignment's value, an element, a block's last line.
def keep(x) = x
keep(ARR = [3, 1, 2])
p ARR.sort
p((N = 20) + 1, N)
TOP = (MID = 7)
p TOP, MID
p [F = 5, F + 1]
class K
  p(INNER = :sym)
  def self.inner = INNER
end
p K.inner, K::INNER
h = keep(H = {a: 1})
h[:b] = 2
p H.size
x = 0
y = (Z = x + 1.5)
p y, Z
keep(BYTES = "abc".bytes)
p BYTES.sum
r = [4].map { |v| DOUBLED = v * 2 }
p r, DOUBLED
def run = yield
p(run { RATE = 3.5 })
p(run { LIST = [1] })
q = if ARGV.empty? then (PICK = [1]) else nil end
p q, PICK
v = (RNG = 1..3).to_a
p v, RNG
k = (SYM = :a) == :a
p k
