# A user is_a? can answer true for another class, so is_a?(K) does not
# narrow to K: the guarded call still reaches the receiver's own method

class Int
  def initialize(v) = @v = v
  def value = @v
end
class Liar
  def is_a?(k) = true
  def value = "liar"
end
def f(x) = x.is_a?(Int) ? x.value : 0
p f(Int.new(1))
p f(Liar.new)
p f(3)
