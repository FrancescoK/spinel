class A
  def initialize(x) = @x = x
  def copy = @x + "c"
  def get(k) = (k == 0 ? @x : copy)
end
src = "s".dup
a = A.new(src)
z = a.get(1)
z << "?"
y = a.get(0)
y << "!"
p z, y, src
