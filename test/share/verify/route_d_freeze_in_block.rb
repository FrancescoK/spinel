s = +"a"; t = s; t << "b"; [s].each(&:freeze); p t.frozen?
