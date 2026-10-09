class A
  def initialize(x) = @x = x
  def get(k) = k == 0 ? "lit" : @x + "c"
end
src = "s".dup; a = A.new(src)
arr = [a.get(1), a.get(0)]
arr[0] << "#"
begin
  arr[1] << "!"
rescue FrozenError => e
  p e.class
end
p arr, arr[1].frozen?, arr[0].frozen?, src
