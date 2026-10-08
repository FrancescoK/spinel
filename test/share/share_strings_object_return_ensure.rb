# spinel: gc-minor
# A concrete method result keeps its selected String through this tail.
class A
  def initialize(x); @x = x; @other = +"other"; end
  attr_reader :other
  def copy = @x + "c"
  def get(k) = begin; @x; ensure; @other; end
end
src = "s".dup
a = A.new(src)
keep = [a.other]
keep[0] << "other"
arr = [a.get(1), a.get(0)]
arr[0] << "#"
arr[1] << "!"
p arr, src
