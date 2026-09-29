# `for` over a range that is not written as a literal at the loop: one held in
# a local, returned by a method, stepped, endless or beginless, and a String
# range.

r = (1..2)
for u in r; end
p u

def rng(n) = (1..n)
for i in rng(3); print i; end
puts

ex = (1...4)
for j in ex; print j; end
puts

for k in (1..10).step(3); print k; end
puts

e = (5..)
for z in e
  break if z > 7
  print z
end
puts

begin
  for y in (..3); end
rescue TypeError => err
  p err.message
end

for s in "a".."c"; print s; end
puts
sr = ("x".."z")
for s2 in sr; print s2; end
puts
p s, s2
