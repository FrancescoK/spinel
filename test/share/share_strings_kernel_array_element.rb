# spinel: share
# spinel: gc-minor
# spinel: gc-stress
# Array(s) makes a new Array whose element is s itself.
s = +"a\0b"
a = Array(s)
p a[0].equal?(s)
a[0] << "!"
p s
s << "?"
p a

def array_element(s)
  Array(s)[0]
end
s = +"method"
t = array_element(s)
t << "!"
p s
s << "?"
p t

1.times do
  s = +"block"
  a = Array(s)
  a[0] << "!"
  p s
  s << "?"
  p a[0]
end

# Already-array inputs retain the Array and its elements.
s = +"existing"
a = [s]
b = Array(a)
p a.equal?(b), b[0].equal?(s)
b[0] << "!"
p s

# Fresh, frozen and non-String inputs keep their existing conversion rules.
a = Array(+"fresh")
a[0] << "!"
p a
s = "frozen"
a = Array(s)
p a[0].equal?(s)
begin
  a[0] << "!"
rescue FrozenError
  p s
end
p Array(nil), Array(2), Array(1.5)
