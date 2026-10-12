# A String Range's endpoint stored in a container is the String the Range
# keeps, so the box read back out is that String: `equal?` against the
# endpoint answers true, in either order. Under --share-strings the
# endpoint read as an operand was boxed again from its bytes, another
# String, once the Range kept a handle for it (#6765).
# spinel: gc-stress

a = +"q"; r = a..; a << "1"
x = [r.begin, 1][0]
p x.equal?(r.begin), r.begin.equal?(x), !x.equal?(r.begin)
p x.object_id == r.begin.object_id, x.__id__ == r.begin.__id__

# a Struct member and a Hash value hold it too
B = Struct.new(:a, :b)
o = B.new(r.begin, 1)
p o.a.equal?(r.begin), [o.a, 2][0].equal?(r.begin)
h = {k: r.begin, n: 1}
p h[:k].equal?(r.begin)

# every endpoint reader, of an inclusive and an exclusive Range
lo = +"a"; hi = +"c"; s = lo..hi; lo << "1"; hi << "2"
xs = [s.begin, s.end, s.first, s.last, s.min, s.max, 1]
p xs[0].equal?(s.begin), xs[1].equal?(s.end), xs[2].equal?(s.first), xs[3].equal?(s.last)
p xs[4].equal?(s.min), xs[5].equal?(s.max), xs[0].equal?(s.end), xs[1].equal?(s.begin)
p s.begin.equal?(xs[0]), s.last.equal?(xs[1]), s.min.equal?(xs[4]), s.max.equal?(xs[5])
e = lo...hi
ys = [e.begin, e.end, 1]
p ys[0].equal?(e.begin), ys[1].equal?(e.end), e.begin.equal?(ys[0]), e.end.equal?(ys[1])

# a box holding another String, or nil, or an Integer, is not the endpoint
others = [+"q1", nil, 1, :q1, r.begin.dup]
p others.map { |v| v.equal?(r.begin) }, others.map { |v| r.begin.equal?(v) }

# in a method, a block and a condition
def same(v, rg) = v.equal?(rg.begin)
p same(x, r), same(others[0], r)
p [x, 2].count { |v| v.equal?(r.begin) }
puts(x.equal?(r.begin) ? "same" : "other")
