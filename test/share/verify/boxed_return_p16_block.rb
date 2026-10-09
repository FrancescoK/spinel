class A
  def initialize(x) = @x = x
  def get(k) = k == 0 ? yield(@x) : @x + "c"
  def each_get
    yield @x
    yield @x + "z"
  end
end
src = "s".dup; a = A.new(src)
arr = [a.get(1) { |s| s }, a.get(0) { |s| s + "b" }]
arr[0] << "#"; arr[1] << "!"
out = []
a.each_get { |s| out << s }
out[0] << "1"; out[1] << "2"
p arr, out, src
