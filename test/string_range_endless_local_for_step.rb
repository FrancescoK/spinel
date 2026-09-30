# An endless String range walks by String#succ. Only an iteration whose
# receiver was the range literal itself did: one held in a local, a for loop
# over one and a step by a variable raised "cannot convert endless range to
# an array".
r = ("a"..)
p r.first(3)
p r.take(2)
p r.find { |x| x > "c" }
p r.each_slice(2).first(2)
p r.lazy.map(&:upcase).first(2)
r.each_with_index { |x, i| print x, i; break if i == 2 }
puts
e = r.each
p e.next
p e.next

for s in ("aa"..)
  next if s == "ab"
  print s, " "
  break if s == "ad"
end
puts
p s

for t in r
  print t
  break if t == "c"
end
puts

n = 2
("a"..).step(n) { |x| print x; break if x >= "e" }
puts
r.step(n) { |x| print x; break if x >= "e" }
puts
STRIDE = 3
p ("a"..).step(STRIDE).first(3)

def names(prefix)
  seq = ("#{prefix}1"..)
  seq.first(3)
end
p names("v")

q = ("a"..)
q = ("a".."c")
p q.first(5)
