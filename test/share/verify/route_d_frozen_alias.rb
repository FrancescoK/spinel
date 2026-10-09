s = +"a"; t = s; t << "b"; s.freeze; p t.frozen?
begin; t << "c"; rescue FrozenError => e; p e.class; end
p s
