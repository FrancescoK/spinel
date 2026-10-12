# --share-strings: a String Range's endpoint boxed in a container is the
# String the Range keeps, the endpoint variable's own: `equal?` against the
# endpoint, the variable or the exclusive Range's #min answers true, and a
# change through the box is a change to the endpoint. The endpoint read as
# an operand was boxed again from its bytes, another String (#6765).
# spinel: gc-stress

a = +"q"; r = (a..)
x = [r.begin, 1][0]
x << "z"
p a, r.begin, x.equal?(r.begin), r.begin.equal?(x), x.equal?(a), a.equal?(x)

lo = +"a"; hi = +"c"; e = lo...hi; lo << "1"
ys = [e.begin, e.min, 1]
p ys[0].equal?(e.min), e.min.equal?(ys[0]), ys[1].equal?(e.begin), ys[1].equal?(lo)

class H
  def initialize; @s = +"q"; @r = (@s..); @s << "1"; end
  def t
    x = [@r.begin, 1][0]
    [x.equal?(@r.begin), x.equal?(@s), @s.equal?(x)]
  end
end
p H.new.t

h = {k: r.begin}
h[:k] << "!"
p a, h[:k].equal?(a), h[:k].equal?(r.begin)
