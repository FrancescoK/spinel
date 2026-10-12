# A method whose last expression, or a `return`, appends to an instance
# variable assignment (`(@a = s) << x`) answers that String: the parameter it
# was handed, which the field now holds, changed in place. The caller's
# String, the field and the method's answer are one object.
class K
  def set(s) = (@a = s) << "!"
  def set5(s) = (@b = s) << "+"
  def set6(s)
    (@c = s) << "#"
  end
  def set7(s)
    return (@d = s) << "?" if s
    nil
  end
  def set8(s)
    return (@e = s) << "%"
  end
  attr_reader :a, :b, :c, :d, :e
end
s = +"x"
k = K.new
r = k.set(s)
p r.equal?(s), k.a.equal?(s), s
t = +"y"
r = k.set5(t)
r << "."
p t, k.b
u = +"z"
w = k.set6(u)
w << "-"
p u, k.c, w.equal?(k.c)
x = +"q"
r = k.set7(x)
r << "3"
p r.equal?(x), k.d.equal?(x), x
y = +"w"
r = k.set8(y)
k.e << "4"
p r.equal?(y), r, y
# the assignment a statement of its own, the append the last one, and the
# field read through its reader
class K2
  def set3(s)
    @a = s
    @a << "?"
  end
  attr_reader :a
end
s3 = +"x"
k2 = K2.new
r3 = k2.set3(s3)
p r3.equal?(s3), k2.a.equal?(s3), s3

# the append in a branch of the method's last expression
class K3
  def t1(s, f)
    if f
      (@a = s) << "1"
    else
      s
    end
  end
  def t2(s, k)
    case k
    when 1 then (@b = s) << "2"
    else s
    end
  end
  def t3(s, f) = f && ((@c = s) << "3")
  def t4(s, f) = f || ((@d = s) << "4")
  def t5(s, f) = f ? ((@e = s) << "5") : s
  attr_reader :a
end
k3 = K3.new
u = +"x"; r = k3.t1(u, true); r << "+"; p u, r.equal?(u), k3.a.equal?(u)
u = +"y"; r = k3.t2(u, 1); r << "+"; p u, r.equal?(u)
u = +"z"; r = k3.t3(u, true); r << "+"; p u, r.equal?(u)
u = +"q"; r = k3.t4(u, false); r << "+"; p u, r.equal?(u)
u = +"v"; r = k3.t5(u, true); r << "+"; p u, r.equal?(u)

# the field starts as nil, set in a parenthesized initialize
class W9
  attr_reader :a
  def initialize = (@a = nil)
  def s(s) = (@a = s) << "!"
end
w9 = W9.new
p w9.a
u9 = +"u"
r9 = w9.s(u9)
p r9.equal?(w9.a), w9.a.equal?(u9), u9
