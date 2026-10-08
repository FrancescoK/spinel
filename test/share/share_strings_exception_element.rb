# Flag-only: `raise a[0]` with a String element of an Array the rule shares
# (boxed as its handle) raises a RuntimeError whose message is that String:
# the rescued `e.message` is the element itself, frozen when the element
# is a frozen literal, and a change through it shows in the element when
# it is not. A begin whose rescue answers `e.message` hands that String on.
a = ["aabc"]
t = begin
  raise a[0]
rescue => e
  e.message
end
p [a[0], t], t.frozen?, t.equal?(a[0])
begin
  t << "x"
  puts "ok"
rescue => e
  p e.class
end
p [a[0], t]
b = [+"mut"]
u = begin
  raise b[0]
rescue => e
  e.message
end
u << "!"
p [b[0], u], u.equal?(b[0])
c = [+"cc"]
begin
  raise c[0]
rescue => e
  p e.class
  e.message << "?"
end
p c
