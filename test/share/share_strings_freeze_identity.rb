# freeze and itself answer their receiver, so `k.freeze.equal?(k)` is true
# for a String the rule shares as well (a key read back from a Hash, which
# the failed append below makes a mutated String).
h = { +"key" => 1 }
fk = h.keys.first
p fk.freeze.equal?(fk), fk.itself.equal?(fk), fk.dup.equal?(fk)
begin; fk << "x"; rescue FrozenError => e; p e.class; end
s = +"s"; t = s; t << "!"
p s.itself.equal?(t), s.freeze.equal?(t), t.frozen?
# The same handle is compared on either side; conversions preserve it,
# while copies remain distinct and a program method keeps its own result.
x = +"x"; y = x; y << "y"
p x.equal?(y.itself), x.to_s.equal?(y), y.equal?(x.to_str)
p x.equal?(y.freeze), x.frozen?, x.clone.equal?(y)
class IdentityOverride
  def itself = +"other"
  def freeze = +"frozen"
end
o = IdentityOverride.new
p o.itself.equal?(o), o.freeze.equal?(o)
p s.freeze.object_id == s.object_id, s.itself.__id__ == s.__id__
p s.to_s.object_id == s.object_id, s.to_str.frozen?, s.itself.frozen?
