class A
  def initialize(x) = @x = x
  def get(k) = k == 0 ? yield(@x) : @x + "c"
end
src = "s".dup; a = A.new(src)
arr = [a.get(1) { |s| s }, a.get(0) { |s| s }]
arr[0] << "#"; arr[1] << "!"
p arr, src
