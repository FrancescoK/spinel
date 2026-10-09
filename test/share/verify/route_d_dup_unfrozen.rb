s = +"a"; t = s; t << "b"; t.freeze; u = s.dup; u << "!"; p u, s, u.frozen?
