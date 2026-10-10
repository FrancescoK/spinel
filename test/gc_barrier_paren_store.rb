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
