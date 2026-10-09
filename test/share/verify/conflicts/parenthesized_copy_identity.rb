class A
  def initialize(x) = @x = x
  def copy = @x + "c"
  def get(k) = (k == 0 ? @x : copy)
  def x = @x
end
src = "s".dup
src << "!"
a = A.new(src)
p a.get(1).equal?(a.x), a.get(0).equal?(a.x), a.get(1)
