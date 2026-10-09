s = +"a"; t = s; t << "b"; p s.hash == t.hash, s.eql?(t), [s].include?(t)
