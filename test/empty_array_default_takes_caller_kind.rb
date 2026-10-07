# An empty `[]` default takes the array kind its callers give the
# parameter, so an ivar it goes into stays typed; it widens when the body
# puts something else in, and stays a poly array when nothing types it.

class Memory
  def initialize(initial = [], length: 4)
    a = initial.dup
    0.upto(length - 1) { |i| a[i] ||= 0 }
    @storage = a
  end
  def peek(i) = @storage[i]
  def poke(i, v) = @storage[i] = v
  def snapshot = @storage.dup
end

class ColorMemory < Memory
  def peek(i) = 0xf0 | @storage[i]
end

INIT = Array.new(4) { |i| i * 2 }.freeze
m = Memory.new(INIT)
m.poke(1, 7)
p m.snapshot
p Memory.new(length: 2).snapshot
p ColorMemory.new([1, 2]).peek(1)

class Names
  def initialize(list: [])
    @list = list
  end
  def all = @list.join(",")
end
p Names.new(list: %w[a b]).all
p Names.new.all

def push_other(a = [])
  a << "x"
  a
end
p push_other([1])
p push_other

def collect(n, acc = [])
  return acc if n == 0
  acc << n
  collect(n - 1, acc)
end
p collect(3)
p collect(2, [9])

def avg(xs = []) = xs.empty? ? 0.0 : xs.sum / xs.size
p avg([1.5, 2.5])
p avg

def untouched(xs = []) = xs.size
p untouched
