# A String bang on a boxed receiver, its value used (`x.strip! || x`), is
# the receiver itself when it changed something and nil when it did not,
# so the chain is the receiver either way, as in CRuby: an Array of
# Strings mapped through it holds the same objects. Under --share-strings
# the value a container keeps is demanded as the shared handle, and the
# chain's left was declared as one but held the transformed bytes: the C
# build stopped. Boxed again, the bytes were a new String.
ws = [+" a ", +"b"]
out = ws.map { |x| x.strip! || x }
p out, out[0].equal?(ws[0]), out[1].equal?(ws[1])
out = ws.map { |x| x.upcase! && x }
p out, out[0].equal?(ws[0])
acc = []
ws.each { |x| acc << (x.downcase! || x) }
p acc, acc[0].equal?(ws[0]), acc[1].equal?(ws[1])
ws.each { |x| y = x.swapcase! || x; y << "?"; p y.equal?(x) }
p ws
ws.each { |x| x.chop! || x }
p ws

# a boxed local, an element, a parameter and an instance variable
mix = [+"ab ", 1, +"cd"]
v = mix[0]
r = v.strip! || v
p r, r.equal?(mix[0])
r = v.strip! || v
p r, r.equal?(v)
r = mix[0].upcase! || mix[0]
p r, r.equal?(mix[0])
def cap(x) = x.capitalize! || x
q = cap(mix[2])
p q, q.equal?(mix[2])
q = cap(mix[2])
p q, q.equal?(mix[2]), mix
class Box
  def initialize(v) = @v = v
  def trim = @v.rstrip! || @v
  def step = @v.succ! || @v
  def v = @v
end
bx = Box.new(mix[0])
mix[0] << "  "
p bx.trim, bx.trim.equal?(bx.v), bx.step.equal?(bx.v), bx.v
Box.new(7)

# handed on as an argument
def chk(a, b)
  b << "#"
  p [b, a.equal?(b)]
end
w = mix[0]
chk(w, w.downcase! || w)
chk(w, w.downcase! || w)
p mix

# bangs with arguments and gsub!/sub!'s block form
mx = [+"ab", 1, +"zz"]
y = mx[0]
r = y.gsub!(/a/) { "A" } || y
p r, r.equal?(mx[0])
r = y.gsub!(/q/) { "Q" } || y
p r, r.equal?(mx[0])
out = mx.values_at(0, 2).map { |e| e.sub!(/z/) { "Z" } || e }
p out, out[1].equal?(mx[2])
r = y.tr!("A", "C") || y
p r, r.equal?(mx[0])
out = mx.values_at(0, 2).map { |e| e.chomp!("b") || e }
p out, out[0].equal?(mx[0]), out[1].equal?(mx[2])

# the bang's value alone: kept by a container, written to a variable
# (a String slot and an `||=`), and a block's value `map` keeps
bv = [+" a ", 1, +"bb"]
e0 = bv[0]
r = e0.strip!
r << "!"
p bv, r.equal?(bv[0])
r = e0.strip!
p r
out = bv.values_at(0, 2).map { |e| e.squeeze! }
p out, out[1].equal?(bv[2])
acc = []
bv.values_at(0, 2).each { |e| acc << e.upcase! }
acc[0] << "?"
p acc, bv
z = nil
z ||= bv[2].swapcase!
p z, z.equal?(bv[2])

# a String the container store makes a handle, beside a boxed result
st = [+" s ", 2]
p st.map { |e| e.to_s.strip || e }

# a bang that changed nothing answers nil: every use of the variable it was
# written to is a call on nil
nb = [+"ab", 1, +"cd"]
n0 = nb[0]
r = n0.strip!
begin; r << "y"; p :shovel; rescue NoMethodError; p [:shovel, :nme]; end
begin; r.concat("y"); p :concat; rescue NoMethodError; p [:concat, :nme]; end
begin; p r.length; rescue NoMethodError; p [:length, :nme]; end
begin; r.upcase!; p :upcase; rescue NoMethodError; p [:upcase, :nme]; end
begin; p r[0]; rescue NoMethodError; p [:aref, :nme]; end
begin; r.insert(0, "y"); p :insert; rescue NoMethodError; p [:insert, :nme]; end
p r.nil?, r.to_s, r.inspect
r3 = (nb[2].downcase!)
begin; r3 << "~"; p :paren; rescue NoMethodError; p [:paren, :nme]; end
p nb
