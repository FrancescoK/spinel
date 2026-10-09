# spinel: share
# spinel: gc-minor
# Splatted Array fill arguments keep the fill object in every element.

s = +"ab"
a = Array.new(*[2, s]); t = a[0]
t << "c"
p s

s = +"ab"
a = Array.new(*[2, s]); t = a[0]
s << "c"
p t

def array_fill_splat_forward
  s = +"ab"
  a = Array.new(*[2, s]); t = a[0]
  t << "c"
  p s
end
array_fill_splat_forward

def array_fill_splat_reverse
  s = +"ab"
  a = Array.new(*[2, s]); t = a[0]
  s << "c"
  p t
end
array_fill_splat_reverse

1.times do
  s = +"ab"
  a = Array.new(*[2, s]); t = a[0]
  t << "c"
  p s
end

1.times do
  s = +"ab"
  a = Array.new(*[2, s]); t = a[0]
  s << "c"
  p t
end

s = +"ab"
a = Array.new(2, *[s]); t = a[0]
t << "c"
p s

s = +"ab"
a = Array.new(2, *[s]); t = a[0]
s << "c"
p t

def array_fill_tail_splat_forward
  s = +"ab"
  a = Array.new(2, *[s]); t = a[0]
  t << "c"
  p s
end
array_fill_tail_splat_forward

def array_fill_tail_splat_reverse
  s = +"ab"
  a = Array.new(2, *[s]); t = a[0]
  s << "c"
  p t
end
array_fill_tail_splat_reverse

1.times do
  s = +"ab"
  a = Array.new(2, *[s]); t = a[0]
  t << "c"
  p s
end

1.times do
  s = +"ab"
  a = Array.new(2, *[s]); t = a[0]
  s << "c"
  p t
end

s = +"ab"
a = Array.new(*[2], s); t = a[0]
t << "c"
p s

s = +"ab"
a = Array.new(*[2], s); t = a[0]
s << "c"
p t

def array_fill_size_splat_forward
  s = +"ab"
  a = Array.new(*[2], s); t = a[0]
  t << "c"
  p s
end
array_fill_size_splat_forward

def array_fill_size_splat_reverse
  s = +"ab"
  a = Array.new(*[2], s); t = a[0]
  s << "c"
  p t
end
array_fill_size_splat_reverse

1.times do
  s = +"ab"
  a = Array.new(*[2], s); t = a[0]
  t << "c"
  p s
end

1.times do
  s = +"ab"
  a = Array.new(*[2], s); t = a[0]
  s << "c"
  p t
end

def fill_once
  n = 0
  a = Array.new(*[2, (n += 1; +"ab")])
  a[0] << "c"
  p a[1]
  p n
end
fill_once

def fill_from_local
  s = +"ab"
  args = [2, s]
  a = Array.new(*args)
  a[0] << "c"
  p s
end
fill_from_local

def copy_from_splat
  s = +"ab"
  a = Array.new(*[[s]])
  a[0] << "c"
  p s
end
copy_from_splat
p Array.new(*[])
p Array.new(*[2])
p Array.new(*[2, 7])
p Array.new(2, *[7])
p Array.new(*[2]) { |i| i + 1 }

# Forwarded and mutated argument arrays separate size and shared fill.
def array_runtime_forward(*args) = Array.new(*args)
s = +"ab"
a = array_runtime_forward(2, s)
a[0] << "c"
p s
s = +"ab"
args = [2]
args << s
a = Array.new(*args)
s << "c"
p a[1]
