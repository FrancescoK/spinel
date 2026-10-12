# Under --share-strings a conditional yielded to a block, handed to a proc
# or a lambda, or to `b.call`, whose arms include a String held as the
# shared handle hands on that String when its arm runs, nil or another
# String when another arm runs: a ternary, `unless`, `&&`, `||`, a `case`,
# an arm that is a bang or an append, beside other arguments, in a
# recursive method, and to a block parameter that also takes other values.
# A block that appends to it, keeps it or stores it changes the receiver; a
# fresh arm is a String of its own.
def tern(s, f) = yield(f ? s : nil)
def either(s, t, f) = yield(f ? s : t)
def fresh(s, f) = yield(f ? s : +"fresh")
def lit(s, f) = yield(f ? s : "lit")
def kase(s, k)
  yield(case k when 1 then s when 2 then nil else +"z" end)
end
def unl(s, f) = yield(unless f then s end)
def first_of(s, f) = yield((f ? s : nil), s)
def second_of(s, t, f) = yield(t, f ? s : nil)
def called(s, f, &b) = b.call(f ? s : nil)
def seq(s, f) = yield(f ? (p 1; s) : nil)
def dup_arm(s, f) = yield(if f then s else s.dup end)
def walk(s, f, n, &b)
  return yield(f ? s : nil) if n == 0
  walk(s, f, n - 1, &b)
end
def app(s, n) = yield(n > 0 ? s << n.to_s : s)
def interp(s, f) = yield(f ? "x#{s}" : s)
def conv(s, f) = yield(f ? s.to_s : nil)
def up(s, f) = yield(f ? s.upcase : s)
def pick(s, f) = f ? s : nil
def picked(s, f) = yield(pick(s, f) || s)
def mixed(s, f)
  yield(f ? s : nil)
  yield(5)
end
def mixed_or(s)
  yield(s.upcase! || s)
  yield(:sym)
end
def mixed_case(s, f)
  yield(case f when true then s.upcase! || s else nil end)
  yield(1.5)
end

s = +"ab"
tern(s, true) { |x| x << "!" if x }
tern(s, false) { |x| p x }
p s

s = +"ab"; t = +"cd"
either(s, t, true) { |x| x << "!" }
either(s, t, false) { |x| x << "?" }
p s, t

s = +"ab"
fresh(s, false) { |x| x << "!"; p x }
fresh(s, true) { |x| x << "!"; p x }
p s

s = +"ab"
lit(s, true) { |x| x << "!" }
begin
  lit(s, false) { |x| x << "!" }
rescue => e
  p e.class
end
p s

s = +"ab"
kase(s, 1) { |x| x << "!" if x }
kase(s, 2) { |x| p x }
kase(s, 3) { |x| x << "?"; p x }
p s

s = +"ab"
unl(s, false) { |x| x << "!" if x }
unl(s, true) { |x| p x }
p s

s = +"ab"
first_of(s, true) { |x, z| x << "!"; p x.equal?(z) }
p s

s = +"ab"; t = +"cd"
second_of(s, t, true) { |a, x| x << "!"; a << "?" }
p s, t

s = +"ab"
pr = proc { |x| x << "!" if x.is_a?(String) }
tern(s, true, &pr)
tern(s, false, &pr)
pr.call(3)
p s

s = +"ab"
l = lambda { |x| x << "!" if x }
tern(s, true, &l)
p s

s = +"ab"
called(s, true) { |x| x << "!" if x }
called(s, false) { |x| p x }
p s

s = +"ab"
k = nil
tern(s, true) { |x| k = x }
k << "!"
p s, k.equal?(s)

s = +"ab"
h = {}
tern(s, true) { |x| h[:k] = x }
h[:k] << "!"
p s

s = +"ab"
r = tern(s, true) { |x| x }
r << "!"
p s

s = +"ab"
tern(s, true) do |x|
  next if x.nil?
  x << "!"
end
tern(s, true) { |x| p x.equal?(s) }
p s

s = +"ab"
tern(s, true) { |x| x.replace("zz") if x }
tern(s, true) { |x| x.upcase! if x }
p s

s = +"ab"
seq(s, true) { |x| x << "!" if x }
p s

s = +"ab"
dup_arm(s, true) { |x| x << "!" }
dup_arm(s, false) { |x| x << "?"; p x }
p s

s = +"ab"
walk(s, true, 2) { |x| x << "!" if x }
p s

s = +"ab"
app(s, 1) { |x| x << "!" }
app(s, 0) { |x| x << "?" }
p s

s = +"ab"
interp(s, true) { |x| x << "!"; p x }
interp(s, false) { |x| x << "?" }
p s

s = +"ab"
conv(s, true) { |x| x << "!" if x }
p s

s = +"ab"
up(s, true) { |x| x << "!"; p x }
up(s, false) { |x| x << "?" }
p s

s = +"ab"
picked(s, true) { |x| x << "!" }
picked(s, false) { |x| x << "?" }
p s

s = +"ab"
mixed(s, true) { |x| x << "!" if x.is_a?(String); p x }
p s

s = +"ab"
mixed_or(s) { |x| x << "!" if x.is_a?(String); p x }
p s

s = +"ab"
mixed_case(s, true) { |x| x << "!" if x.is_a?(String) }
p s
