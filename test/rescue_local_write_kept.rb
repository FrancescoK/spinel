# A local written between a rescue's setjmp and the raise keeps the value
# after the rescue: through `x rescue y` (a modifier rescue), and inside a
# block that an inlined yielding method runs under its own rescue.

def boom(x)
  raise "x" if x != 0
  x
end

n = 1
v = (boom(n += 4) rescue nil)
p n
p v

s = "a"
f = 1.5
(boom((s = "b"; f = 2.5; 3)) rescue 0)
p s
p f

def in_method
  t = 10
  u = (boom(t *= 3) rescue -1)
  [t, u]
end
p in_method

def guard
  yield
rescue
  :rescued
end

m = 1
r = guard { m += 10; raise "e" }
p m
p r

def guard_begin
  begin
    yield
  rescue ArgumentError
    :arg
  end
end

w = "w"
g = guard_begin { w = "x"; raise ArgumentError }
p w
p g

def counts
  c = 0
  guard { c += 1; boom(c) }
  c
end
p counts
