# A statement assignment through a boxed receiver whose classes have two
# writers of the name, an attr_accessor (or a Struct member) and an explicit
# `def a=`: each class stores the String itself, so a change through the
# right-hand side shows in the field, for a safe-navigation and a plain
# call, a nil receiver skipped, and each receiver counted to run once; the
# assignment's value is that String whichever writer ran.
class K
  attr_accessor :a
  def initialize = (@a = +"k")
end
class M
  attr_reader :z
  def initialize = (@z = +"m")
  def a=(v)
    @z = v
  end
end
S = Struct.new(:a)

$n = 0
def rec(x) = ($n += 1; x)
o = K.new
m = M.new
st = S.new(+"st")
s = +"s"
t = s
b = [o, m, st, nil][0]
rec(b)&.a = s
s << "!"
p o.a, o.a.equal?(t)
c = [o, m, st, nil][1]
rec(c)&.a = s
s << "?"
p m.z, o.a, m.z.equal?(s)
d = [o, m, st, nil][2]
rec(d).a = s
s << "#"
p st.a, st.a.equal?(s)
e = [o, m, st, nil][3]
rec(e)&.a = s
p $n, s

# the value is the right-hand side's String whichever writer ran: kept,
# chained, through a plain call, a new String, a nil receiver, an explicit
# writer that dups (its field is the copy, the value is not)
class D
  attr_reader :a, :n
  def initialize = (@a = +"d"; @n = 0)
  def a=(v)
    @n += 1
    @a = v.dup
  end
end
dw = D.new
u = +"u"
r = (rec(b)&.a = u)
r << "1"
p [o.a, u, r.equal?(u)]
r = (rec(c).a = u)&.<<("2")&.<<("3")
p [m.z, u, r.equal?(u)]
r = (rec([o, m, st, dw, nil][3])&.a = u)
r << "4"
p [dw.a, u, r.equal?(u), dw.n]
(rec([dw, o][0])&.a = u)&.<<("5")&.<<("6")
p [dw.a, u, dw.n]
r = (rec(e)&.a = u)
p r
q = (rec(b)&.a = +"fresh")
q << "!"
p [o.a, q, q.equal?(o.a)]
p $n

# one explicit writer through a boxed receiver, given a new String
class E
  attr_reader :e
  def initialize = (@e = +"e")
  def e=(v)
    @e = v
  end
end
ew = E.new
eq = [ew, nil][0]
r = (rec(eq)&.e = +"new")
r << "!"
p [ew.e, r, r.equal?(ew.e), $n]
