# An operator on a boxed value widens only the classes it can hold
# A `+` on a boxed receiver goes to the runtime's operator dispatch, which
# hands the argument over boxed, so the parameter of every `+` it can reach
# takes anything (#3511). It reached every class's `+`: a `q + 1` on a value
# that is only ever an Integer or a String boxed Vec#+'s parameter, and
# Vec#+ and Vec#dot went boxed with it. A value that can be a Money still
# widens Money#+, and Money#+ takes an Integer and a Money there.

Vec = Struct.new(:x, :y) do
  def +(o) = Vec.new(x + o.x, y + o.y)
  def dot(o) = x * o.x + y * o.y
end

class Money
  attr_reader :cents
  def initialize(cents) = @cents = cents

  def +(other)
    other.is_a?(Money) ? Money.new(@cents + other.cents) : Money.new(@cents + other)
  end
end

a = Vec.new(1.0, 2.0)
b = Vec.new(0.5, 0.25)
s = 0.0
100.times { a = a + b; s += a.dot(b) }
p s, a

q = { "k" => [1, "two"] }["k"][ARGV.size]
p q + 1

m = [Money.new(5), "x"][ARGV.size]
p (m + 3).cents, (m + Money.new(7)).cents
