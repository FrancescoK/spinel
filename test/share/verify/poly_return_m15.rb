class A
  def initialize(x) = @x = x
  def get = @x
end
src = "s".dup
a = A.new(src)
arr = [a.get, a.get]
arr[1] << "!"
p arr, src
