# An Integer spliced into a Float array through a poly receiver stays an
# Integer, as in CRuby: the splice does not write it back as a Float.
def put(arr, src) = (arr[1, src.length] = src)
def widen(h) = h.is_a?(Integer) ? h : h
w = widen([0.5, 1.5, 2.5])
w[1, 1] = [7].first(1)
p w
fs = [0.5, 1.5, 2.5]
put(widen(fs), [nil, 9.5].first(2))
p fs
