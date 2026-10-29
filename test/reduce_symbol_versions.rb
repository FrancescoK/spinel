# inject(:op) and inject(init, :op) call the method the Symbol names on the
# elements, as `&:op` does: the method it reaches runs the version of what it
# calls that is defined when it runs, before a later def of that name and
# after it. An operator and a plain name.
def k = 1
class V
  attr_reader :n
  def initialize(n) = @n = n
  def **(o) = V.new(n + o.n + k)
  def combine(o) = V.new(n * o.n + k)
end
p [V.new(2), V.new(3)].inject(:**).n
p [V.new(2), V.new(3)].reduce(:combine).n
p [V.new(2), V.new(3)].inject(V.new(1), :combine).n
def k = 100
p [V.new(2), V.new(3)].inject(:**).n
p [V.new(2), V.new(3)].reduce(:combine).n
p [V.new(2), V.new(3)].inject(V.new(1), :combine).n
