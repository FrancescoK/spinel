def put(h, k) = (h[k] = 1)
s = +"k"; t = s; t << "!"; h = {}; put(h, s); t << "?"; p h, h.keys[0].frozen?
