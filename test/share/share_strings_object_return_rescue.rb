# spinel: gc-minor
# A concrete method result keeps its selected String through this tail.
class A
  def initialize(x) = @x = x
  def copy = @x + "c"
  def get(k) = begin; raise "x" if k == 1; @x; rescue; copy; end
end
src = "s".dup
a = A.new(src)
arr = [a.get(1), a.get(0)]
arr[0] << "#"
arr[1] << "!"
p arr, src
