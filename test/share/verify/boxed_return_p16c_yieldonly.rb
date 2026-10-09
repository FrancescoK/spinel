class A
  def initialize(x) = @x = x
  def get = yield(@x)
end
src = "s".dup; a = A.new(src)
arr = [a.get { |s| s }, a.get { |s| s + "b" }]
arr[0] << "#"; arr[1] << "!"
p arr, src
