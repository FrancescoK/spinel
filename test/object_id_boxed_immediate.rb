# spinel: int64
# An immediate's object_id is the same whether the value is read typed or
# out of a box: an Array's element, a Hash's key, a method's boxed answer
def boxed_id(x) = x.object_id
def ident(x) = x

dyn = "dyn_1".to_sym
lit = :lit
int = 7
neg = -3
fl = 2.5
nz = -0.0
t = true
f = false
n = nil
typed = [dyn, lit, int, neg, fl, nz, t, f, n].map { |v| v }
vals = [dyn, lit, int, neg, fl, nz, t, f, n]
ids = [dyn.object_id, lit.object_id, int.object_id, neg.object_id, fl.object_id,
       nz.object_id, t.object_id, f.object_id, n.object_id]
names = %w[dyn_sym lit_sym int neg_int float neg_zero true false nil]
h = {}
vals.each_with_index { |v, i| h[v] = i }
names.each_with_index do |nm, i|
  puts "#{nm}: element #{vals[i].object_id == ids[i]} " \
       "key #{h.keys[i].object_id == ids[i]} " \
       "call #{boxed_id(vals[i]) == ids[i]} " \
       "return #{ident(vals[i]).object_id == ids[i]} " \
       "map #{typed[i].object_id == ids[i]}"
end

# the same Symbol however it is reached, and different Symbols apart
a = ["dyn_1".to_sym]
b = "dyn_1".to_sym
p b.object_id == a[0].object_id
p a[0].object_id == :dyn_1.object_id
syms = [:a, :b, "c".to_sym, "dyn_1".to_sym]
p syms.map(&:object_id).uniq.size
p syms.map(&:object_id).include?(b.object_id)
p [:a.object_id == [:b][0].object_id, 1.object_id == [2][0].object_id]
p({k: 1}.keys[0].object_id == :k.object_id)
p 3.object_id == [3][0].object_id

# an Integer past half the range: the typed and boxed ids agree
big = 2**62 - 1
p [big][0].object_id == big.object_id, boxed_id(-big) == (-big).object_id
