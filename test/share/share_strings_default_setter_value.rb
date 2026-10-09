# spinel: share
# spinel: gc-minor
# The setter's expression value and the Hash default keep the argument itself.
s = +"a\0b"
h = {}
t = (h.default = s)
p t.equal?(s), h.default.equal?(s)
t << "c"
p s, h.default
s << "d"
p t, h[:missing]

def default_value(s)
  h = {}
  h.default = s
end
s = +"method"
t = default_value(s)
t << "!"
p s
s << "?"
p t

1.times do
  s = +"block"
  h = {}
  t = begin
    h.default = String(s)
  ensure
    10.times { "garbage" * 100 }
  end
  p t.equal?(s)
  t << "!"
  p s, h.default
  s << "?"
  p t
end

h = {}
t = (h.default = +"fresh")
t << "!"
p h.default
h.default << "?"
p t

t = (h.default = "frozen")
p t.equal?(h.default)
begin
  t << "!"
rescue FrozenError
  p h.default
end

# The receiver and the argument run once, in order, before the frozen check.
$events = []
def default_receiver(h)
  $events << :receiver
  h
end
def default_argument(s)
  $events << :argument
  s
end
s = +"ordered"
h = {}
t = (default_receiver(h).default = default_argument(s))
t << "!"
p s, h.default, $events
h.freeze
begin
  default_receiver(h).default = default_argument(s)
rescue FrozenError
  p $events
end
