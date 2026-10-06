# Class values that reach an ordering through a source no flow is followed
# from -- a Proc's or a Method's answer, send, define_method, an
# Enumerator, Object.const_get, catch, a Struct member, an attribute
# writer, instance_variable_set -- count as possibly classes, so two
# unrelated ones answer nil as Module#< does, and related ones true or
# false.
class A; end
class B < A; end
class C; end
def ka = A
def kc = C
pa = -> { A }
pc = proc { C }
pb = -> { B }
p [pa.call < pc.call, pa.() <= pc.(), pa.yield > pc.yield, pb.call < pa.call]
ma = method(:ka)
mc = method(:kc)
p [ma.call >= mc.call, send(:ka) < send(:kc), __send__(:kc) > ma.call]
class K
  define_method(:dk) { A }
end
p K.new.dk < C
p Object.const_get(:A) < Object.const_get(:C)
p catch(:t) { throw :t, A } < C
S = Struct.new(:a, :b)
s = S.new(A, C)
p s.a < s.b
class Box
  attr_accessor :k
end
x = Box.new
x.k = pa.call
y = Box.new
y.k = pc.()
p x.k < y.k
z = Box.new
z.instance_variable_set(:@k, pb.call)
p [z.k < x.k, z.k < y.k]
p [A, C].each_slice(1).to_a[0][0] < [A, C].each_slice(1).to_a[1][0]
p A.then { |v| v } < C.tap { }
en = [A, C].each
p en.next < en.next
h = {}
h[:a] = pa.call
h[:c] = pc.call
p h[:a] < h[:c]
$g1 = pa.call
$g2 = pc.call
p [$g1 < $g2, $g1 > B]
