# spinel: gc-stress
# A store the emitter writes as a parenthesised statement, `((k)->iv = v);`
# (instance_variable_set with its value dropped), takes its write barrier
# after the value is stored like any other statement. Wrapped as an
# expression the barrier ran before the value was built, and an allocation
# that collected in between left the old holder unrecorded: the new value
# was freed while the ivar still held it.
class K
  def initialize
    @text = +"i"
    keep = @text
    @text << "!"
    @list = [1]
    @map = { 0 => 0 }
    @node = nil
  end
  def text = @text
  def list = @list
  def map = @map
  def node = @node
end

class Node
  def initialize(n) = (@n = n)
  attr_reader :n
end

k = K.new
10.times do |i|
  k.instance_variable_set(:@text, +"v#{i}")
  p k.text
  k.instance_variable_set(:@list, [i, i + 1])
  p k.list
  k.instance_variable_set(:@map, { i => i * 2 })
  p k.map
  k.instance_variable_set(:@node, Node.new(i))
  p k.node.n
  k.instance_variable_set(:@text, "lit")
  p k.text
end

# a generated constructor stores all its fields in one statement, and each
# value is built after the stores before it: every store takes its own
# barrier, since building a later value can collect
U = Struct.new(:x, :y, :z) do
  def initialize(a) = super(a * 2, a.upcase, a.reverse)
end
us = []
6.times { |i| us << U.new("u#{i}") }
us.each { |o| p o.to_a }

# the first field stored is an Integer, a Float or a bool, which needs no
# barrier, and a later one is built by a call that allocates objects: the
# barrier still follows each reference store
def boxes(a)
  t = []
  8.times { |k| t << Node.new(k) }
  a.upcase
end
M1 = Struct.new(:n, :s) do
  def initialize(a) = super(a.size, boxes(a))
end
M2 = Struct.new(:f, :node) do
  def initialize(a) = super(a.size * 0.5, Node.new(a))
end
M3 = Struct.new(:ok, :c) do
  def initialize(a) = super(a.size.even?, a.chars)
end
M4 = Struct.new(:n, :s) do
  def initialize(a) = super([a.size, 3].max, boxes(a))
end
# an earlier value whose C holds a string literal with a bracket, a quote,
# an escaped quote or a trailing backslash in it
M5 = Struct.new(:n, :s) do
  def initialize(a) = super("#{a})".size, boxes(a))
end
M6 = Struct.new(:n, :s) do
  def initialize(a) = super("#{a}\")'(".size, boxes(a))
end
M7 = Struct.new(:n, :s) do
  def initialize(a) = super("#{a}\\".size, boxes(a))
end
ms = []
60.times do |i|
  a = "m#{i}"
  ms << M1.new(a) << M2.new(a) << M3.new(a) << M4.new(a) << M5.new(a) << M6.new(a) << M7.new(a)
  Array.new(20) { |k| Node.new(k) }
end
p(ms.each_slice(7).count { |m1, m2, m3, m4, m5, m6, m7|
  m1.s.downcase == m3.c.join && m2.node.n == m3.c.join && m4.s == m1.s &&
    m5.s == m1.s && m6.s == m1.s && m7.s == m1.s && m6.n == m5.n + 3 && m7.n == m5.n
})
p ms[0].to_a, ms[1].f, ms[1].node.n, ms[2].to_a, ms[4].to_a, ms[5].to_a, ms[6].to_a, ms[-1].to_a
