# A String method of the program's own that answers what it yields
# (`def pm(a) = yield(a)`) runs through its proc form; the block's value
# is the call's: a String the block hands back is that String itself, as
# kept, frozen or new as it was, through a write, a method's return and
# a block that turns a frozen String into a new one with unary +.
# a call ahead of a reopening's definition reaches the builtin
r0 = "x".center(5) { |v| v }
p r0
class String
  def pm(a) = yield(a)
end
$k = []
s = +"hello"
s << " world"
t = s
r = (+"ab").pm(s) { |v| v << "!"; $k << v; v }
s << "?"
p r, $k, t, r.equal?(s)
s2 = +"abc"
s2 << "d"
r2 = (+"ab").pm(s2) { |v| $k << v; v.size }
s2 << "e"
p r2, $k
r3 = "ab".pm(s) { |v| v.capitalize }
s.replace("Z" * 50)
p r3
w = "lit"
r4 = "ab".pm(w) { |v| (+v) << "!" }
p r4, w, r4.equal?(w), r4.frozen?
u = +"mm"
u.freeze
r5 = "ab".pm(u) { |v| (+v) << "%" }
p r5, u, r5.equal?(u)
m = +"mu"
m << "t"
r6 = "ab".pm(m) { |v| (+v) << "&" }
p m, r6.equal?(m)
r7 = "ab".pm(w) { |v| v }
p r7.frozen?, r7.equal?(w)
def mk(x)
  (+"ab").pm(x) { |v| v }
end
k = mk(s)
k << "1"
p s, k.equal?(s)
def mk2(x)
  "q".pm(x) { |v| (+v) << "+" }
end
k2 = mk2(m)
k2 << "2"
p m, k2.equal?(m)
k3 = mk2("fz")
p k3, k3.frozen?
# a reopening's method of a builtin name that yields wins over the builtin,
# as in CRuby, and hands on the block's String as the others do
class String
  def center(a) = yield(a)
end
c = +"cn"
c << "t"
rc = (+"ab").center(c) { |v| v }
rc << "!"
p c, rc.equal?(c)
p("ab".center("x") { |v| v + "?" })
# a reopening's each_char whose block captures the caller's locals
class String
  def each_char
    i = 0
    while i < size
      yield self[i]
      i += 1
    end
    self
  end
end
acc = +""
"abc".each_char { |ch| acc << ch << "." }
cnt = 0
"xy".each_char { |ch| cnt += 1 }
p acc, cnt
