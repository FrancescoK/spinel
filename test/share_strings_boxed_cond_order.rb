# Boxed conditional arms run their setup after the predicate, only on the
# chosen path, and after earlier statements in that arm. Calls with two
# String arguments force hoisted, rooted setup; untaken setup can raise.
# spinel: gc-minor
def choose(v)
  puts "predicate"
  v
end
def part(n)
  puts n
  n.to_s
end
def joined(a, b)
  puts "joined"
  a + b
end
def boom(n)
  puts n
  raise "boom"
  ""
end
c = ARGV.empty?
s = +"s"
t = +"t"
a = [0, choose(c) ? (s << joined(part(1), part(2))) : (t << joined(boom(3), part(4)))]
p a
h = {zero: 0, value: (unless choose(c)
  t << joined(boom(5), part(6))
else
  puts "hash arm"
  s << joined(part(7), part(8))
end)}
p h[:value]
x = 0
x = if choose(!c)
  s << joined(boom(9), part(10))
else
  puts "box arm"
  t << joined(part(11), part(12))
end
p x
nested = [0, if choose(c)
  puts "outer arm"
  if choose(!c)
    s << joined(boom(13), part(14))
  else
    puts "inner arm"
    t << joined(part(15), part(16))
  end
else
  s << joined(boom(17), part(18))
end]
p nested
begin
  a = [0, choose(c) ? (s << joined(boom(19), part(20))) : (t << joined(part(21), part(22)))]
rescue RuntimeError => e
  puts e.message
end
p [0, (s << joined(boom(23), part(24)) if choose(!c))]
# The handle-valued emitter uses the same arm buffer.
u = s
u = if choose(c)
  puts "handle arm"
  t << joined(part(25), part(26))
else
  s << joined(boom(27), part(28))
end
p u
