# A Symbol's object_id is no other kind's: not nil's, true's or false's
# fixed id, not an Integer's, and not another Symbol's -- read typed or out
# of a box alike
def boxed_id(x) = x.object_id

syms = [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, "dyn_1".to_sym]
fixed = [nil.object_id, true.object_id, false.object_id]
ints = (-20..20).map(&:object_id)
typed = syms.map { |s| s.object_id }
boxed = syms.map { |s| boxed_id(s) }

p typed == boxed
p typed.uniq.size == syms.size
p (typed & fixed).empty?
p (typed & ints).empty?
p (boxed & fixed).empty?
p [:foo.object_id == false.object_id, :foo.object_id == nil.object_id,
   :foo.object_id == true.object_id]
p [[:a][0].object_id == :a.object_id, {k: 1}.keys[0].object_id == :k.object_id]
p typed.all? { |i| i.is_a?(Integer) }
