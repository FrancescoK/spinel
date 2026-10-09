# spinel: share
# spinel: gc-minor
# A boxed Hash default keeps its argument at the first ordered evaluation.
$ev = []
def r(h)
  $ev << :r
  h
end
def a(s)
  $ev << :a
  s
end
s = +"s"
h = {}
s << "1"; t = (r(h).default = a(s))
p $ev, t, h[:x], s
t << "!"
p h[:y], s
h2 = {}
x = (h2.default = (h2.default = s))
x << "?"
p s, h2[:q]
h3 = {}
y = (h3.default = s.tap { |q| h3[:k] = 1 })
p h3, y.equal?(s)
def get_h
  $ev << :gh
  {}
end
z = (get_h.default = a(s))
p $ev
fh = {}.freeze
begin
  (r(fh).default = a(s << "Z"))
rescue FrozenError
  p $ev, s
end

$events = []
def receiver(x)
  $events << :receiver
  x
end
def value(x)
  $events << :value
  x
end
s = +"source"
h = {}
t = (receiver(h).default = value(s))
p t.equal?(s), h[:missing].equal?(s)
t << "!"
p s, h[:missing]
p $events
old = h
x = (receiver(h).default = (h = {}; value(s)))
p x.equal?(s), old[:missing].equal?(s), h.empty?
f = {}.freeze
begin
  receiver(f).default = value(s << "?")
rescue FrozenError
  p s, $events
end
