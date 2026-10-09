s = +"a"; t = s.itself; t << "b"; s.freeze; p t.frozen?, s
