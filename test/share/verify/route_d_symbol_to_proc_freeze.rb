s = +"a"; t = s; t << "b"; s.then(&:freeze); p t.frozen?
