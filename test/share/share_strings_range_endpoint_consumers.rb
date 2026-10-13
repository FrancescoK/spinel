# --share-strings: a String Range's endpoint (begin, end, first, last,
# min, max) is the String the Range keeps, wherever it is handed: as an
# element (also beside a later operand that changes a String), an
# argument, an instance variable, a block's parameter, a method's return
# and a Struct member. Each consumer keeps the identity (`equal?`) and a
# change through it reaches the variable and the Range. Where the
# endpoint is held as the handle, its representation says so: it is the
# handle the Range keeps, not a new one wrapped around its bytes, and the
# emitters that hold an operand or an argument ahead of its call take it
# as the String, with the handle read off the Range.
# spinel: gc-stress

S = Struct.new(:lo, :hi)

class Box
  attr_accessor :v
  def initialize(v) = @v = v
end

def keep(x, y) = [x, y]
def give(r) = r.min
def give2(r) = (r.end)
def each_end(r)
  yield r.begin
  yield r.max
end

def same(xs, a, b) = xs.map { |x| x.equal?(a) || x.equal?(b) }

a = +"a"; b = +"c"; r = a..b

# elements: a literal, a push beside a later operand that changes a
# String, an insert, an index write and a Hash value
xs = [r.begin, r.end, r.first, r.last, r.min, r.max]
p same(xs, a, b)
ys = []
ys.push(r.begin, (a << "1"; r.end))
ys.insert(1, r.min)
ys[3] = r.max
ys.push(r.first, (b << "x"; 1))
h = { lo: r.first, hi: r.last }
p same(ys.first(5), a, b), same(h.values, a, b)
ys[0] << "2"; h[:hi] << "3"
p a, b, r

# arguments, also held ahead of a later operand that changes a String
k = keep(r.first, (b << "4"; r.last))
p same(k, a, b)
k[0] << "5"
p a

# instance variables, through initialize and a writer
o = Box.new(r.begin)
p o.v.equal?(a)
o.v = r.max
p o.v.equal?(b)
o.v << "6"
p b

# a block's parameter
got = []
each_end(r) { |x| got << x }
p same(got, a, b)
got[0] << "7"
p a

# a method's return
m = give(r)
n = give2(r)
p m.equal?(a), n.equal?(b)
m << "8"; n << "9"
p r

# a Struct member
s = S.new(r.min, (a << "0"; r.max))
p s.lo.equal?(a), s.hi.equal?(b)
s.hi << "!"
p b, r

# a Range of literals keeps no handle: its endpoint is the String it holds
q = "x".."z"
zs = [q.begin, q.begin, q.max]
p zs, zs[0].equal?(zs[1]), zs[0].frozen?
