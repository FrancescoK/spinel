# Under --share-strings a String bang's value yielded to a block, or handed
# to a proc or a lambda, is the receiver's String when the bang changed it,
# and nil when it did not, and a mutator that answers its receiver
# (`insert`, `<<`, `concat`, `replace`) yields the receiver's String: the
# block's parameter takes the receiver's handle, typed, boxed or through a
# proc's argument. A block that appends to it, keeps it, stores it or
# replaces it changes the receiver, also when the receiver is a Struct
# member or an attribute's instance variable, and a proc called with a bang
# on a boxed element changes that element.
def up(s) = yield(s.upcase!)
def up_sub(s) = yield(s.sub!("a", "z"))
def up_strip(s) = yield(s.strip!)
def up_gsub(s) = yield(s.gsub!(/a/) { "z" })
def up_insert(s) = yield(s.insert(0, "x"))
def up_append(s) = yield(s << "x")
def up_concat(s) = yield(s.concat("x", "y"))
def up_replace(s) = yield(s.replace("zz"))
def up_member(o) = yield(o.t.upcase!)
def up_paren(s) = yield((s.upcase!))
def up_pair(s) = yield(s.upcase!, s.downcase!)
def up_then_append(s) = yield(s.upcase!, (s << "x"))
def up_call_append(s, &b) = b.call(s.upcase!, (s << "x"))
def up_mixed(s, o)
  yield(s.upcase!)
  yield(o)
end
def walk(s, n, &b)
  return yield(s.upcase!) if n == 0
  walk(s, n - 1, &b)
end
def run(s, pr) = pr.call(s.upcase!)

S = Struct.new(:t)

class Holder
  attr_reader :s
  def initialize(s) = @s = s
  def each_up
    yield @s.upcase!
    yield @s.upcase!
  end
end

s = +"ab"
r = up_sub(s) { |x| x << "!"; x }
r << "?"
p s, r

s = +"ab"
up(s) { |x| x.replace("new") }
p s

s = +" ab "
up_strip(s) { |x| x << "!" }
p s

s = +"ab"
up_gsub(s) { |x| x << "!" }
p s

o = S.new(+"ab")
up_member(o) { |x| x << "!" }
p o.t

s = +"ab"
up_insert(s) { |x| x << "!" }
p s
s = +"ab"
up_append(s) { |x| x << "!" }
p s
s = +"ab"
up_concat(s) { |x| x << "!" }
p s
s = +"ab"
up_replace(s) { |x| x << "!" }
p s

s = +"ab"
arr = [s]
up(s) { |x| x << "!" }
p arr

s = +"ab"
store = {}
up(s) { |x| store[:k] = x }
store[:k] << "!"
p s

s = +"ab"
up(s) { |*xs| xs[0] << "!" }
p s

s = +"ab"
pr = proc { |x| x << "!" if x }
up(s, &pr)
up(s, &pr)
p s

s = +"ab"
l = lambda { |x| x << "!" }
up(s, &l)
p s

s = +"ab"
up_paren(s, &pr)
p s

s = +"ab"
pr.call(s.upcase!)
p s

s = +"ab"
l2 = ->(x) { x << "!" if x; x }
p l2.(s.upcase!), s
t = +"AB"
p l2[t.upcase!], t

s = +"ab"
run(s, proc { |x| x << "!" })
p s

a = [+"ab", 1]
p pr.call(a[0].upcase!), a

s = +"ab"
up_pair(s) { |x, y| p x.equal?(y), x; y << "!" if y }
p s

s = +"ab"
up_then_append(s) { |x, y| x << "!"; p x.equal?(y) }
p s

s = +"ab"
up_call_append(s) { |x, y| x << "!"; p x.equal?(y) }
p s

s = +"ab"
up_mixed(s, 5) { |x| x << "!" if x.is_a?(String); p x }
p s

s = +"ab"
walk(s, 3) { |x| x << "!" if x }
walk(s, 2) { |x| p x }
p s

hd = Holder.new(+"ab")
hd.each_up { |x| x << "!" if x; p x }
p hd.s
