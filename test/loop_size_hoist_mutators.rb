# A `while` that tests a String local's size does not hoist the size out of
# the loop when its body changes the String with any String mutator, those
# that answer the String or nil (chop!, succ!, delete!, ...) included.
n = 0
s = +"abcdef"
while s.size > 3 && n < 20
  s.chop!
  n += 1
end
p s, n

n = 0
s = +"zzzz"
while s.size < 5 && n < 20
  s.succ!
  n += 1
end
p s, n

n = 0
s = +"aabbcc"
while s.size > 4 && n < 20
  s.delete!("a")
  n += 1
end
p s, n

n = 0
s = +"aabbcc"
while s.size > 3 && n < 20
  s.squeeze!
  n += 1
end
p s, n

n = 0
s = +"abcdef"
while s.size > 2 && n < 20
  s.slice!(0)
  n += 1
end
p s, n

n = 0
s = +"  ab  "
while s.size > 4 && n < 20
  s.lstrip!
  s.rstrip!
  n += 1
end
p s, n

n = 0
s = +"abc"
while s.size < 6 && n < 20
  s.prepend("x")
  n += 1
end
p s, n

n = 0
s = +"abc"
while s.size > 0 && n < 20
  s.clear
  n += 1
end
p s, n

n = 0
s = +"abcd"
while s.size > 2 && n < 20
  s.replace(s[1..])
  n += 1
end
p s, n

n = 0
s = +"abcd"
while s.size > 2 && n < 20
  s.tr!("a-b", "")
  s.chomp!("d")
  n += 1
end
p s, n
