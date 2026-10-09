s = "lit"; t = s; p s.equal?(t), t.frozen?
begin; t << "x"; rescue FrozenError; p :fz; end
