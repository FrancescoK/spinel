# `@a[f(i)] = v` as a statement on an Array of mixed elements reads @a
# before f runs, as the typed Arrays' store does: f assigning @a a new
# Array leaves that one as f built it, and the store lands in the Array
# read first.
class Swap
  def initialize = @data = ["a", 1, "c"]
  def swap(i) = (@data = ["z", 2, "x"]; i)
  def swapv(v) = (@data = ["w", 3, "v"]; v)
  def reset = @data = ["a", 1, "c"]

  def put(i)
    @first = @data
    @data[swap(i)] = "q"
    nil
  end

  def put_value(i)
    @first = @data
    @data[i] = swapv(:r)
    nil
  end

  def show = p(@first, @data)
end

s = Swap.new
s.put(0)
s.show
s.reset
s.put_value(1)
s.show
