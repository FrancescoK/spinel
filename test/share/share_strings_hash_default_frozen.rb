# spinel: share
# spinel: gc-minor
def receiver(h) = h
receiver(1)
def text(s, n)
  n == 0 ? "frozen" : s
end
s = +"source"
h = {}
x = (receiver(h).default = text(s, ARGV.size))
y = text(s, ARGV.size)
begin
  x << "!"
rescue FrozenError
end
p x.equal?(y), h[:missing].equal?(y), s
def literal_text = "frozen"
z = (receiver(h).default = literal_text)
GC.start
p z.equal?(literal_text), z.equal?("frozen"), h[:missing].equal?(z), z.frozen?
u = (receiver(h).default = text(s, 1))
u << "!"
p u.equal?(s), h[:missing].equal?(s), s
