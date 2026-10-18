# `@a[f(i)] = v` as a statement reads @a before f runs, as Ruby does, even
# when f assigns @a a new Array: the store lands in the Array read first.
# The receiver was read inside the C call's argument list, where gcc ran
# f first and stored into the new Array.
class Swap
  def initialize = @data = ["a", "b", "c"]
  def swap(i) = (@data = ["z", "y", "x"]; i)

  def put(i)
    @data[swap(i)] = "q"
    nil
  end

  def data = @data
end
w = Swap.new
w.put(0)
p w.data

class Nums
  def initialize = @n = [1, 2, 3]
  def bump(i) = (@n = [7, 8, 9]; i)

  def put(i)
    @n[bump(i)] = 0
    nil
  end

  def n = @n
end
z = Nums.new
z.put(1)
p z.n

$g = [1, 2]
def reset_g(i) = ($g = [5, 6]; i)
$g[reset_g(0)] = 9
p $g
