# Flag-only: without the flag (as on master) each route hands over a copy
# and misses the change.
# A route that answers the String it is handed, not a new one, hands over
# the handle when the rule shares that String: a begin's value, `then` and
# `yield_self` (also under `||=` and a multiple assignment), `+s`, `String(s)`,
# a class method answering a class variable, a Hash's default (read, or read
# for a missing key), a Thread's and a Fiber's value, a proc's answer, what a
# block answers to `yield` (into an ivar, or as an inlined method's value),
# the key `fetch` hands its block, and a value a `break` leaves `loop` with
# or a `next` leaves a `then` or a yielded block with (not one that leaves
# a nested block or loop), a route in a conditional's arm or after `||`,
# a Thread's or a yield's value that can be nil, a then block ending in
# begin/rescue, a top-level or initialize ivar written a route, and a method
# answering `x.then { |v| v }`, and `next s` out of a Hash.new or an
# Array.new block. A change through a route receiver
# (`(+s).upcase!`, `(+s)[0] = x`, `pr.call << x`, `setbyte`, `bytesplice`,
# `append_as_bytes`, a begin's value) reaches the String too, a route with
# a block runs it once, and a route that answers nil raises NoMethodError
# as a nil receiver does.
s = +"a"
x = begin; s; rescue; nil; end
s << "1"
p x
r = s.then { |v| v }
r << "2"
q = nil
q ||= s.yield_self { |v| v }
q << "3"
m, n = s.then { |v| v }, 1
m << "4"
p s, n
f = s.then { |v| v + "f" }
f << "!"
p s, f
s = +"b"
(+s) << "1"
(+s).upcase!
(+s).replace("c")
(+s)[0] = "C"
(+s).insert(1, "<")
u = String(s)
u << ">"
String(s) << "2"
p s
t = "lit"
(+t) << "!"
p t
class K
  def self.set(v) = (@@g = v)
  def self.g = @@g
end
s = +"c"
K.set(s)
K.g << "1"
k = K.g
k << "2"
p s
h = {}
h.default = s
h.default << "3"
h[:missing] << "4"
p s, h, h[:other]
s = +"d"
w = Thread.new { s }.value
w << "1"
Thread.new { s }.join.value << "2"
fb = Fiber.new { s }
fb.resume << "3"
p s
pr = proc { s }
pr.call << "4"
l = -> { s }
l.() << "5"
l[].upcase!
p s, proc { nil }.call
class Y
  def set = (@a = yield)
  def a = @a
end
def yv = yield
o = Y.new
s = +"e"
o.set { s }
s << "1"
z = yv { s }
z << "2"
p o.a, s
{}.fetch(s) { |key| key << "3" }
p s
$n = 0
s = +"g"
s.then { |v| $n += 1; v } << "1"
s.then { |v| $n += 1; v }.upcase!
p s, $n
i = 0
r = loop do
  i += 1
  while true
    break
  end
  [1, 2].each { |k| next if k == 1 }
  break s if i > 2
end
r << "2"
z = loop { break s + "z" }
z << "!"
w = s.then do |x|
  [1].each { |k| next }
  next x if x.size > 1
  x + "?"
end
w << "3"
v = yv do
  [3].map { |k| next k + 1 }
  next s if s.size > 1
  s
end
v << "4"
p s, z, i, loop { break nil }
c = s.size > 1
b = c ? s.then { |v| v } : nil
b << "5"
e = if c then String(s) else nil end
e << "6"
f = nil || s.then { |v| v }
f << "7"
Thread.new { c ? s : nil }.value << "8"
yv { c ? s : nil } << "9"
g = s.then { |v| begin; raise "x"; rescue; v; end }
g << "a"
p s
s = +"hi"
(+s).setbyte(0, 72)
String(s).bytesplice(1, 1, "I")
(begin; s; rescue; nil; end).append_as_bytes("!")
(begin; s; rescue; nil; end) << "?"
(begin; s; rescue; nil; end)[0] = "h"
@iv = s.then { |v| v }
@iv << "1"
@jv = String(s)
@jv << "2"
class Box
  def initialize(s) = (@iv = s.then { |v| v })
  def go = (@iv << "3")
end
Box.new(s).go
def r1(x) = x.then { |v| v }
r1(s) << "4"
p s
n = nil
n = +"x" if ARGV.size > 5
[-> { (+n) << "1" }, -> { (+n).upcase! }, -> { proc { n }.call << "2" }, -> { loop { break n }.upcase! },
 -> { loop { break n }[0] = "Q" }, -> { (begin; n; rescue; nil; end) << "3" }].each do |l|
  l.call
  p :no_error
rescue NoMethodError => e
  p e.class
end
m = +"ab"
mk = m
mk << "1"
m = nil if ARGV.empty?
pm = proc { m }
begin; (+m).upcase!; rescue NoMethodError => e; p e.class; end
begin; (+m)[0] = "Q"; rescue NoMethodError => e; p e.class; end
begin; pm.call.upcase!; rescue NoMethodError => e; p e.class; end
begin; pm.call << "2"; rescue NoMethodError => e; p e.class; end
begin; loop { break m }[0] = "Q"; rescue NoMethodError => e; p e.class; end
begin; loop { break m }.replace("Q"); rescue NoMethodError => e; p e.class; end
begin; (begin; m; rescue; nil; end).upcase!; rescue NoMethodError => e; p e.class; end
p m, mk
q = +"q"
Hash.new { |hh, k| next q }[:z] << "1"
hq = Hash.new { |hh, k| next q if k == :a; q }
hq[:a] << "2"
Array.new(2) { |i| next q }[1] << "3"
p q
$log = []
def li = ($log << :i; 0)
def lb = ($log << :v; 90)
sb = +"ob"
(+sb).setbyte(li, lb)
String(sb).setbyte(li + 1, lb - 1)
p sb, $log
def yo(a) = yield(a)
o2 = +"o2"
y = yo(o2) { |x| x.then { |v| v }.size > 0 ? x : nil }
y << "!"
p o2
