# Under --share-strings a String Range's endpoint handed on as an argument
# is the endpoint String, also where an argument after it changes the
# endpoint in place and the arguments run ahead of the call: a box takes
# the handle the Range keeps, and parentheses that change the endpoint
# before their value run once.
B = Struct.new(:a, :b)
B.new(1, 2)
f = (+"a")..(+"c")
bx = B.new(f.min, (f.begin << "y"; f.min))
p bx.a, bx.b, f
bx = B.new(f.end, (f.end << "z"; f.end))
p bx.a, f
S = Struct.new(:a, :b)
g = (+"a").."c"
st = S.new(g.begin, (g.begin << "x"; g.begin))
p st.a, g
def pair(a, b) = [a, b]
pair(1, 2)
p pair(g.first, (g.begin << "w"; g.first)), g
