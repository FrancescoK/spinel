class A
  def initialize(x) = (@x = x; @n = 0)
  def get(k)
    @n += k
    @x
  end
end
src = "s".dup; a = A.new(src)
arr = [a.get(1), a.get(0)]
arr[0] << "#"
p arr, src
