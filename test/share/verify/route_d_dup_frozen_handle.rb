s = +"a"; t = s; t << "b"; s.freeze; u = t.dup; u << "!"; p u, u.frozen?, t
