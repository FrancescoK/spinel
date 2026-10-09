s = +"k"; t = s; t << "!"; h = [s].each_with_object({}) { |x, acc| acc[x] = 1 }; t << "?"; p h
