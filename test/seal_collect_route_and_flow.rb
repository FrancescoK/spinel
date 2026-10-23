# The two String representations refused this program; with one it answers as CRuby.
# Two refusals of the seal: a route (a boxed to_s with an arm answering nil
# hands the String of the other arm on as a variable's write) and a flow (an
# Object method's ivar read stored as an element). Without SP_COLLECT_ERRORS
# the run stops at the first; with it, it reports both (collect-errors-test).
class Own
  def initialize(n) = (@n = n)
  def to_s = @n
  def n = @n
end
class Nope
  def to_s = nil
end
def tidy(o)
  s = o.to_s
  return "nil" if s.nil?
  s << "!"
  s
end
a = Own.new(+"a")
p tidy(a), tidy(Nope.new), a.n
class Object
  def label = @label
end
class Labelled
  def initialize(s) = (@label = s)
end
class OtherLabel
  def label = +"other"
end
s = +"text"
objects = [Labelled.new(s), OtherLabel.new, 5]
labels = [objects[0].label, objects[1].label]
labels[0] << "!"
p labels, s, objects[2].label
