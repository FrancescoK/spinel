class A
  def initialize(x) = @x = x
  def get(k) = @x + "c"
end
src = "s".dup; a = A.new(src)
arr = [a.get(1)]
arr.insert(1, a.get(1))
arr.each_with_index { |s, i| s << i.to_s }
p arr
