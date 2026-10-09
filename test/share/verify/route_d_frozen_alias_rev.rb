s = +"a"; t = s; t << "b"; t.freeze; p s.frozen?
begin; s << "c"; rescue => e; p e.class; end
