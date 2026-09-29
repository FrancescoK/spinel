# A yielding initialize takes its **kwrest like any other call: the
# keywords no declared keyword names, in source order, with or without a
# block, from literals and from a `**` of a hash.
$log = []
def tr(x) = ($log << x; x)

class P
  attr_reader :o
  def initialize(**o) = (@o = o; yield self if block_given?)
end
p P.new.o
p P.new(a: 1).o
p P.new(a: 1, b: 2) { |x| $log << :blk }.o

class Q
  attr_reader :n, :k, :o
  def initialize(n, k: 0, **o)
    @n = n; @k = k; @o = o
    yield self if block_given?
  end
end
q = Q.new(1, k: 2, z: 3)
p [q.n, q.k, q.o]
q = Q.new(tr(1), z: tr(3), k: tr(2), y: tr(4)) { |x| $log << x.o.size }
p [q.n, q.k, q.o]
h = { z: 5, w: 6 }
q = Q.new(7, **h)
p [q.n, q.k, q.o]
q = Q.new(8, a: 1, **h) { |x| x }
p [q.n, q.k, q.o]
p $log

# a named keyword from a `**`, and a key that is no Symbol
h2 = { k: 9, v: 1 }
q = Q.new(2, **h2) { |x| x }
p [q.n, q.k, q.o]
q = Q.new(3, "s" => 1, k: 4)
p [q.n, q.k, q.o]
$log.clear
def hh = ($log << :hh; { u: 1 })
q = Q.new(tr(5), **hh, w: tr(6))
p [q.n, q.k, q.o, $log]
