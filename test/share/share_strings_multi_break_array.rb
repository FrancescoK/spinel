# spinel: share
# spinel: gc-minor
# Multiple break values form one Array and retain their element identities.

s = +"ab"
a = loop { break 1, s }; t = a[1]
t << "c"
p s

s = +"ab"
a = loop { break 1, s }; t = a[1]
s << "c"
p t

def break_forward
  s = +"ab"
  a = loop { break 1, s }; t = a[1]
  t << "c"
  p s
end
break_forward

def break_reverse
  s = +"ab"
  a = loop { break 1, s }; t = a[1]
  s << "c"
  p t
end
break_reverse

1.times do
  s = +"ab"
  a = loop { break 1, s }; t = a[1]
  t << "c"
  p s
end

1.times do
  s = +"ab"
  a = loop { break 1, s }; t = a[1]
  s << "c"
  p t
end

p(loop { break 1, 2 })
p(loop { break 1, *[2, 3] })
p([1].each { break 1, 2 })
p(while true; break 1, 2; end)
p(1.times { break nil, 2 })
