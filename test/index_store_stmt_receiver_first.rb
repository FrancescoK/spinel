# `@a[f(i)] = v` as a statement reads @a before f runs, as Ruby does, even
# when f assigns @a a new Array: the store lands in the Array read first,
# and the new one is left as f built it. The receiver was read inside the
# C call's argument list, where gcc ran f first and stored into the new
# Array; an index or a value that runs statements of its own (a block, a
# rescue) ran them before the receiver was read.
class Swap
  def initialize = @data = ["a", "b", "c"]
  def swap(i) = (@data = ["z", "y", "x"]; i)
  def reset = @data = ["a", "b", "c"]

  def put(i)
    @first = @data
    @data[swap(i)] = "q"
    nil
  end

  def put_rescued(i)
    @first = @data
    @data[i] = begin
      swap(i)
      "r"
    rescue
      "e"
    end
    nil
  end

  def put_block_index(i)
    @first = @data
    @data[[i].map { |k| swap(k) }.first] = "b"
    nil
  end

  def first = @first
  def data = @data
end
w = Swap.new
w.put(0)
p w.first, w.data
w.reset
w.put_rescued(1)
p w.first, w.data
w.reset
w.put_block_index(2)
p w.first, w.data

class Nums
  def initialize = @n = [1, 2, 3]
  def bump(i) = (@n = [7, 8, 9]; i)

  def put(i)
    @first = @n
    @n[bump(i)] = 0
    nil
  end

  def first = @first
  def n = @n
end
z = Nums.new
z.put(1)
p z.first, z.n

$g = [1, 2]
g0 = $g
def reset_g(i) = ($g = [5, 6]; i)
$g[reset_g(0)] = 9
p g0, $g
