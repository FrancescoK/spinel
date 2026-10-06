# A Float Array's chunk_while, slice_when, chunk, slice_before and
# slice_after with a block answer an Enumerator over the runs, as the
# Integer, String and poly Arrays' do, wherever the value goes: a local,
# an Array element, an argument. The call typed as nothing, and a value of
# no type boxed into a poly slot is nil: `x = a.chunk_while { }` held nil,
# and the Array literal holding one did not build. An untyped receiver's
# `sum` is the empty Array's answer only when the receiver is one.

def runs(e) = e.to_a

a = [1.0, 2.0, 4.0, 5.0, 7.5]
x = a.chunk_while { |i, j| j == i + 1 }
p x.class
p x.to_a
y = a.slice_when { |i, j| j != i + 1 }
p y.to_a
z = a.chunk { |v| v > 2 }
p z.to_a
w = a.slice_before { |v| v > 3 }
p w.to_a
v = a.slice_after { |v| v > 3 }
p v.to_a
l = [a.chunk_while { |i, j| j > i }, 1]
p l[0].class
p l[0].to_a
p runs(a.slice_when { |i, j| j < i })
e = [2.5]
e.pop
p e.chunk_while { |i, j| true }.to_a
p [].sum
b = []
p b.sum(0.5)
p [1.5, 2.5].sum
