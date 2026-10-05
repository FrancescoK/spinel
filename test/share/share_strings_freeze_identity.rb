# Flag-only: without the flag (as on master) freeze and itself answer a copy here.
# freeze and itself answer their receiver, so `k.freeze.equal?(k)` is true
# for a String the rule shares as well (a key read back from a Hash, which
# the failed append below makes a mutated String).
h = { +"key" => 1 }
fk = h.keys.first
p fk.freeze.equal?(fk), fk.itself.equal?(fk), fk.dup.equal?(fk)
begin; fk << "x"; rescue FrozenError => e; p e.class; end
s = +"s"; t = s; t << "!"
p s.itself.equal?(t), s.freeze.equal?(t), t.frozen?
