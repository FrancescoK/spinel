# spinel: share
# spinel: gc-minor
# Collected block results retain their handles before the Array is named.

s = +"ab"
t = [1].map { next s }[0]
t << "c"
p s

s = +"ab"
t = [1].map { next s }[0]
s << "c"
p t

def next_map_forward
  s = +"ab"
  t = [1].map { next s }[0]
  t << "c"
  p s
end
next_map_forward

def next_map_reverse
  s = +"ab"
  t = [1].map { next s }[0]
  s << "c"
  p t
end
next_map_reverse

1.times do
  s = +"ab"
  t = [1].map { next s }[0]
  t << "c"
  p s
end

1.times do
  s = +"ab"
  t = [1].map { next s }[0]
  s << "c"
  p t
end

s = +"ab"
t = [1].collect { next s }[0]
t << "c"
p s

s = +"ab"
t = [1].collect { next s }[0]
s << "c"
p t

def next_collect_forward
  s = +"ab"
  t = [1].collect { next s }[0]
  t << "c"
  p s
end
next_collect_forward

def next_collect_reverse
  s = +"ab"
  t = [1].collect { next s }[0]
  s << "c"
  p t
end
next_collect_reverse

1.times do
  s = +"ab"
  t = [1].collect { next s }[0]
  t << "c"
  p s
end

1.times do
  s = +"ab"
  t = [1].collect { next s }[0]
  s << "c"
  p t
end

s = +"ab"
t = [1].map { s }[0]
t << "c"
p s

s = +"ab"
t = [1].map { s }[0]
s << "c"
p t

def block_map_forward
  s = +"ab"
  t = [1].map { s }[0]
  t << "c"
  p s
end
block_map_forward

def block_map_reverse
  s = +"ab"
  t = [1].map { s }[0]
  s << "c"
  p t
end
block_map_reverse

1.times do
  s = +"ab"
  t = [1].map { s }[0]
  t << "c"
  p s
end

1.times do
  s = +"ab"
  t = [1].map { s }[0]
  s << "c"
  p t
end

def conditional_map
  s = +"ab"
  t = [1, 2].map { |i| next s if i == 1; s.dup }[0]
  t << "c"
  p s
end
conditional_map

def fresh_map
  s = +"ab"
  t = [1].map { s.dup }[0]
  t << "c"
  p s
  p t
end
fresh_map

def frozen_map
  s = "ab"
  t = [1].map { s }[0]
  begin
    t << "c"
  rescue FrozenError
    puts "frozen"
  end
end
frozen_map
