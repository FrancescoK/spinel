s = "lit"; t = s
begin; s << "x"; rescue FrozenError => e; p e.message; end; p t
