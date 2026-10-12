# A String Range's endpoint read twice among one call's arguments, with an
# argument between the reads that changes the endpoint in place
# (`B.new(f.min, (f.begin << "y"; f.min))`), is one String, as in CRuby.
# Built --share-strings, the parenthesized read ran into a copy of the
# endpoint's bytes. Covered: min / first / last / max, into Struct members
# of no static class, instance variables, a Hash and boxed parameters.
C2 = Struct.new(:a, :b)
C2.new(1, 2)
q = (+"a")..(+"c")
cx = C2.new(q.min, (q.begin << "y"; q.min))
p cx.a.equal?(cx.b)
cx = C2.new(q.first, (q.begin << "y"; q.first))
p cx.a.equal?(cx.b)
cx = C2.new(q.last, (q.end << "z"; q.last))
p cx.a.equal?(cx.b)
m = 0
cx = C2.new(q.max, ((m += 1; q.end << "z"); q.max))
p cx.a.equal?(cx.b), m
class P; def initialize(a, b); @a = a; @b = b; end; def same = @a.equal?(@b); end
P.new(1, 2)
p P.new(q.begin, (q.begin << "y"; q.begin)).same
def put(hh, a, b) = (hh[:a] = a; hh[:b] = b; hh)
hh = put({a: nil, b: nil}, q.end, (q.begin << "q"; q.end))
p hh[:a].equal?(hh[:b])
def both(a, b) = a.equal?(b)
both(1, 2)
p both(q.min, (q.begin << "y"; q.min))
