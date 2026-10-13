# A constant assigned a local that holds a Module.new or Class.new value
# names that module or class: `include Q` includes it, and `class K`
# reopens it, as an `include` of the module's own constant does.
k = Class.new do
  def hi = "hi"
end
K = k
class K
  def more = "more"
end
p K.new.hi, K.new.more, K.name, k.name
q = Module.new do
  def inst = "inst"
end
Q = q
class C
  include Q
end
p C.new.inst, C.include?(Q), C.ancestors.include?(q)
helpers = Module.new do
  def twice(x) = x * 2
end
Helpers = helpers
class Calc
  include Helpers
  def run = twice(21)
end
p Calc.new.run
