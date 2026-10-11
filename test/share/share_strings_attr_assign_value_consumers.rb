# spinel: gc-minor
# The value of an attribute assignment, taken by a consumer that holds the
# handle (an Array element, a Hash value, a global, a proc's result, a
# `return`), is the very String the writer was handed. Each class has its
# own copy of the helpers: a receiver of several classes stays refused.
class Acc
  attr_accessor :a
  def initialize = (@a = +"x")
end
class Wr
  attr_reader :a
  def initialize = (@a = +"x")
  def a=(v)
    @a = v
    0
  end
end
S = Struct.new(:a)

def arr_acc(o, s)
  list = []
  list << (o.a = s)
  list[0] << "1"
  p [o.a, s, list]
end
def hsh_acc(o, s)
  h = {}
  h[:k] = (o.a = s)
  h[:k] << "2"
  p [o.a, s, h]
end
def glob_acc(o, s)
  $g_acc = (o.a = s)
  $g_acc << "3"
  p [o.a, s, $g_acc]
end
def prc_acc(o, s)
  f = proc { (o.a = s) }
  r = f.call
  r << "4"
  p [o.a, s, r]
end
def ret_acc(o, s)
  return (o.a = s) if s.size > 0
  +"none"
end
def arr_st(o, s)
  list = []
  list << (o.a = s)
  list[0] << "1"
  p [o.a, s, list]
end
def hsh_st(o, s)
  h = {}
  h[:k] = (o.a = s)
  h[:k] << "2"
  p [o.a, s, h]
end
def glob_st(o, s)
  $g_st = (o.a = s)
  $g_st << "3"
  p [o.a, s, $g_st]
end
def prc_st(o, s)
  f = proc { (o.a = s) }
  r = f.call
  r << "4"
  p [o.a, s, r]
end
def ret_st(o, s)
  return (o.a = s) if s.size > 0
  +"none"
end
def arr_wr(o, s)
  list = []
  list << (o.a = s)
  list[0] << "1"
  p [o.a, s, list]
end
def hsh_wr(o, s)
  h = {}
  h[:k] = (o.a = s)
  h[:k] << "2"
  p [o.a, s, h]
end
def glob_wr(o, s)
  $g_wr = (o.a = s)
  $g_wr << "3"
  p [o.a, s, $g_wr]
end
def prc_wr(o, s)
  f = proc { (o.a = s) }
  r = f.call
  r << "4"
  p [o.a, s, r]
end
def ret_wr(o, s)
  return (o.a = s) if s.size > 0
  +"none"
end

arr_acc(Acc.new, +"s")
hsh_acc(Acc.new, +"s")
glob_acc(Acc.new, +"s")
prc_acc(Acc.new, +"s")
s = +"s"
r = ret_acc(Acc.new, s)
r << "6"
p [r, s]
arr_st(S.new(+"x"), +"s")
hsh_st(S.new(+"x"), +"s")
glob_st(S.new(+"x"), +"s")
prc_st(S.new(+"x"), +"s")
s = +"s"
r = ret_st(S.new(+"x"), s)
r << "6"
p [r, s]
arr_wr(Wr.new, +"s")
hsh_wr(Wr.new, +"s")
glob_wr(Wr.new, +"s")
prc_wr(Wr.new, +"s")
s = +"s"
r = ret_wr(Wr.new, s)
r << "6"
p [r, s]

# a block's value that a yield hands on (the method answers the yield), with
# and without parentheses, and the block of a user-defined `each`
def yl = yield
o = Wr.new
s = +"s"
yl { (o.a = s) } << "7"
p [o.a, s]
o = Wr.new
s = +"s"
yl { o.a = s } << "8"
p [o.a, s]
class Coll
  def each = yield
end
o = Wr.new
s = +"s"
r = Coll.new.each { o.a = s }
r << "9"
p [o.a, s, r]
o = Wr.new
s = +"s"
yl { o.a = s }
s << "0"
p [o.a, s]
