def fz(h, *a) = h.fetch(*a)
p fz({a: 1}, :b, 3)
p fz({a: 1}, :a)
p fz([1, 2], 5, 9)
p fz([1, 2], 1)
begin
  fz({a: 1})
rescue ArgumentError
  puts "fetch with no arguments: ArgumentError"
end

def fk(h, k, *a) = h.fetch(k, *a)
p fk({a: 1}, :z, 5)

def fl(a, *r) = a.first(*r)
p fl([1, 2, 3], 2)
p fl([1, 2, 3])
def ll(a, *r) = a.last(*r)
p ll([1, 2, 3], 2)
p ll([1, 2, 3])

def ix(s, *r) = s.index(*r)
p ix("abcabc", "b", 2)
p ix("abcabc", "b")

def ar(a, *r) = a[*r]
p ar([1, 2, 3, 4], 1, 2)
p ar([1, 2, 3, 4], -1)
p ar("hello", 1, 3)

def sp(s, *r) = s.split(*r)
p sp("a,b,c", ",", 2)
p sp("a b")

def sw(s, *r) = s.start_with?(*r)
p sw("hello", "x", "he")
def cn(s, *r) = s.count(*r)
p cn("hello", "lo", "o")
def jn(a, *r) = a.join(*r)
p jn([1, 2], "-")
p jn([1, 2])
def lj(s, *r) = s.ljust(*r)
p lj("ab", 5, "*")
def sm(a, *r) = a.sum(*r)
p sm([1, 2], 10)
def ts(i, *r) = i.to_s(*r)
p ts(255, 16)

x = [1, 2, 3]
def set(a, *r) = a.[]=(*r)
set(x, 0, 2, 9)
p x

$calls = 0
def hh
  $calls += 1
  {a: 1}
end
def once(*a) = hh.fetch(*a)
p once(:b, 7)
p $calls

args = [:q, "dflt"]
p [1, 2].map { |i| {a: 5}.fetch(*args) + i.to_s }
