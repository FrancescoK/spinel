# spinel: gc-minor
# The value of an attribute assignment is its right-hand side: the very String
# the writer was handed, whatever the writer stores or returns.
S = Struct.new(:a, :b)
class Acc
  attr_accessor :a
  def initialize = (@a = +"x")
end
class Wr
  attr_writer :a
  def initialize = (@a = +"x")
  def show = @a
end
class Dup
  attr_reader :a
  def initialize = (@a = +"x")
  def a=(v)
    @a = v.dup
    :ignored
  end
end
class Same
  attr_reader :a
  def initialize = (@a = +"x")
  def a=(v)
    @a = v
    42
  end
end

s = S.new(+"x", 1)
y = +"y"
r = (s.a = y)
t = s.a
t << "!"
p [s.a, y, r, r.equal?(y), s.a.equal?(y)]

acc = Acc.new
y = +"y"
r = (acc.a = y)
r << "!"
p [acc.a, y, r, r.equal?(acc.a)]
r = (acc.a = +"fresh")
r << "?"
p [acc.a, r, r.equal?(acc.a)]

wr = Wr.new
y = +"y"
r = (wr.a = y)
r << "!"
p [wr.show, y, r]

d = Dup.new
y = +"y"
r = (d.a = y)
r << "!"
p [d.a, y, r, r.equal?(y), d.a.equal?(y)]

m = Same.new
y = +"y"
r = (m.a = y)
r << "!"
p [m.a, y, r, r.equal?(y), m.a.equal?(y)]
r = (m.a = +"fresh")
r << "?"
p [m.a, r, r.equal?(m.a)]

def keep(s) = s
def set_acc(o, s) = (o.a = s)
def set_same(o, s) = (o.a = s)
acc = Acc.new
y = +"y"
r = keep(acc.a = y)
r << "1"
list = []
list << (acc.a = y)
list[0] << "2"
p [acc.a, y, r, list]
z = +"z"
q = set_acc(acc, z)
q << "3"
p [acc.a, z, q]
m = Same.new
z = +"z"
q = set_same(m, z)
q << "4"
p [m.a, z, q]

$acc = Acc.new
def recv = (puts "recv"; $acc)
def rhs = (puts "rhs"; +"v")
r = (recv.a = rhs)
r << "!"
p [$acc.a, r, r.equal?($acc.a)]

acc = Acc.new
ids = []
3.times do
  r = (acc.a = "lit")
  ids << r.equal?(acc.a)
  p r.frozen?
end
p ids, acc.a.frozen?

a = Acc.new
b = Acc.new
y = +"y"
r = a.a = b.a = y
r << "!"
p [a.a, b.a, y, r]

# the assignment as a statement: its value is dropped, and the field still
# names the String
st = S.new(+"x")
y = +"y"
st.a = y
y << "1"
p [st.a, y]
def stmt_same(o, s)
  o.a = s
  s << "2"
  p [o.a, s]
end
stmt_same(Same.new, +"s")
def stmt_acc(o, s)
  o.a = s
  s << "3"
  p [o.a, s]
end
stmt_acc(Acc.new, +"s")

# through a safe navigation, the value and the statement
m = Same.new
y = +"y"
r = (m&.a = y)
r << "4"
p [m.a, y, r]
y = +"y"
m&.a = y
y << "5"
p [m.a, y]
n = nil
y = +"y"
p [(n&.a = y), y]

# the assignment in a branch of a statement: the conditional's value is dropped
def branch(o, s, f)
  o.a = s if f
  begin; o.a = s; rescue; end
  if f then o.a = s end
  s << "6"
  p [o.a, s]
end
branch(Same.new, +"s", true)
