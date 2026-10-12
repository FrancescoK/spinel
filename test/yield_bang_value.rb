# A String bang's value yielded to a block is the receiver's String when the
# bang changed it, and nil when it did not. A block that appends to it, keeps
# it or compares it with the receiver sees the receiver's String, whether the
# bang is the yield's only argument or one of several, on a local, a
# parameter, an instance variable or a global, and through `block.call`.
def up(s) = yield(s.upcase!)
def up_paren(s) = yield((s.upcase!))
def up_two(s) = yield(s.upcase!, s)
def up_second(s, t) = yield(t, s.upcase!)
def up_twice(s)
  yield(s.upcase!)
  yield(s.downcase!)
end
def up_each(s)
  [1, 2].each { |i| yield(s.upcase!, i) }
end
def up_call(s, &b) = b.call(s.upcase!)
def up_nested(s) = up(s) { |x| yield x }
def both(s, t) = yield(s.upcase!, t.upcase!)

class Holder
  def initialize = @s = +"iv"
  def up = yield(@s.upcase!)
  def s = @s
end

$g = +"gv"
def up_gvar = yield($g.upcase!)

s = +"ab"
up(s) { |x| x << "!" }
p s

s = +"AB"
r = up(s) { |x| x }
p r, s

s = +"ab"
r = up(s) { |x| x }
r << "!"
p r, s

s = +"ab"
up_paren(s) { |x| x << "!" }
p s

s = +"ab"
up_two(s) { |x, z| x << "!"; p x.equal?(z) }
p s

s = +"ab"; t = +"cd"
up_second(s, t) { |a, x| x << "!"; a << "?" }
p s, t

s = +"ab"
keep = nil
up(s) { |x| keep = x }
keep << "!"
p s, keep

s = +"ab"
up_twice(s) { |x| x << "!" if x; p x }
p s

s = +"ab"
up(s) { |x| p x.equal?(s) }

s = +"ab"
up_each(s) { |x, i| x << i.to_s if x }
p s

s = +"ab"
up_call(s) { |x| x << "!" }
p s

s = +"ab"
k = nil
up_call(s) { |x| k = x }
k << "!"
p s

s = +"ab"
up(s) do |x|
  next if x.nil?
  x << "!"
end
up(s) { |x| p x }
p s

s = +"ab"
up_nested(s) { |x| x << "!" }
p s

s = +"ab"; t = +"CD"
both(s, t) { |a, b| a << "!"; p b }
p s, t

h = Holder.new
h.up { |x| x << "!" }
p h.s

up_gvar { |x| x << "!" }
p $g

s = "ab"
begin
  up(s) { |x| x << "!" }
rescue => e
  p e.class
end
p s
