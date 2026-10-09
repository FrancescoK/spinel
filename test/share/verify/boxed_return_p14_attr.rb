class A
  attr_reader :x
  def initialize(x) = @x = x
end
src = "s".dup; a = A.new(src)
arr = [a.x, a.x]
arr[0] << "#"
p arr, src, a.x
