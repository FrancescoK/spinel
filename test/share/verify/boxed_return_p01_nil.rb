class A
  def initialize(x) = @x = x
  def get(k) = k == 0 ? nil : @x + "c"
end
src = "s".dup; a = A.new(src)
arr = [a.get(1), a.get(0), a.get(2)]
arr[0] << "#"
arr[2] << "!"
p arr, arr.compact, arr[1].nil?, src
