s = +"lit"; u = s; u << "x"; t = -s; p t.frozen?, t.equal?(s), s.frozen?
begin; t << "!"; rescue FrozenError; p :fz; end; p s
