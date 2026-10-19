# The value of a fill on a boxed receiver stays alive while an allocating
# start or length expression runs: a fresh Array, or a String held only by
# one, was collected before the fill stored it.
class Img
  def initialize(bytes) = @bytes = bytes
  attr_reader :bytes
  def pair(i) = [i.to_s * 3, i]
  def ary(n) = @bytes.fill(pair(n), churn(1), churn(n))
  def str(n) = @bytes.fill(pair(n).first, churn(1), churn(n))
  def churn(n)
    junk = []
    2000.times { |i| junk << "j#{i}" * 20 << [i, i.to_s] }
    n
  end
end

p Img.new(+"text").bytes.size
a = Img.new([1, "a", nil, :b])
a.ary(2)
p a.bytes
s = Img.new([1, "a", nil, :b])
s.str(2)
p s.bytes
