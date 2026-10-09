class P
  attr_reader :n
  def initialize(n) = @n = n
  def label(k) = k == 0 ? "p" : "p" + @n.to_s
end
pt = P.new(3)
arr = [pt.label(1), pt.label(1)]
arr[0] << "#"
p arr
