# spinel: gc-minor
# instance_variable_set on a receiver nothing else holds, `(a || b)` or a
# `case`, with its value dropped: the receiver is held while the value is
# built. Building it can collect, and the store then landed in the freed
# receiver, which by then could be a live object allocated in its place.
# Both the frozen-checked form (a class the program freezes) and the plain
# one.
class Fh
  def initialize(n) = (@n = n; @text = +"seed")
  def text = @text
end
class Ph
  def initialize(n) = (@n = n; @text = +"seed")
  def text = @text
end
Fh.new(0).freeze

def fresh_f(i) = Fh.new(i)
def fresh_p(i) = Ph.new(i)
$kept = []
def build(i)
  8.times { |k| $kept << Fh.new(k) << Ph.new(k) }
  "s" + i.to_s
end

i = 0
while i < 120
  (fresh_f(i) || fresh_f(0)).instance_variable_set(:@text, build(i))
  (fresh_p(i) || fresh_p(0)).instance_variable_set(:@text, build(i))
  case i % 2 when 0 then fresh_f(i) else fresh_f(1) end.instance_variable_set(:@text, build(i))
  case i % 2 when 0 then fresh_p(i) else fresh_p(1) end.instance_variable_set(:@text, build(i))
  i += 1
end
p $kept.size, $kept.map(&:text).uniq

# the value is still the stored one
v = (fresh_f(1) || fresh_f(2)).instance_variable_set(:@text, build(7))
w = (fresh_p(1) || fresh_p(2)).instance_variable_set(:@text, build(8))
p v, w

# the value used, on self in a method of the class: the store is a statement
# of its own and the slot read after it is the value, so its barrier follows
# the value however the C compiler orders the two
class Pa
  def initialize(n) = (@n = n; @arr = [0])
  attr_reader :arr
  def put(i) = self.instance_variable_set(:@arr, Pa.build_a(i))
  def self.build_a(i)
    8.times { |k| $kept << Fh.new(k) }
    [i, i + 1]
  end
end
pas = []
60.times { |j| pas << Pa.new(j).tap { |o| o.put(j) } }
p pas.map(&:arr).each_with_index.count { |a, j| a == [j, j + 1] }
