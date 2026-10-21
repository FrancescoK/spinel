# Random#rand raises ArgumentError for an empty Float range (descending, or an
# exclusive range with equal ends) before it draws.
r = Random.new(5)
begin
  r.rand(3.5..1.5)
  puts :ok
rescue => e
  p [e.class, e.message]
end
r = Random.new(5)
begin; r.rand(3.5...1.5); rescue => e; p [e.class, e.message]; end
begin; r.rand(3.5..1); rescue => e; p [e.class, e.message]; end
begin; r.rand(3..1.5); rescue => e; p [e.class, e.message]; end
begin; r.rand(3...1.5); rescue => e; p [e.class, e.message]; end
begin; r.rand(2.5...2.5); rescue => e; p [e.class, e.message]; end
begin; r.rand(2...2.0); rescue => e; p [e.class, e.message]; end
p r.rand(2.5..2.5)
r = Random.new(5)
a = 3.5..1.5
c = 2.5...2.5
begin; r.rand(a); rescue => e; p [e.class, e.message]; end
begin; r.rand(c); rescue => e; p [e.class, e.message]; end
r = Random.new(5)
control = Random.new(5)
begin
  r.rand(3.5..1.5)
rescue => e
  p [e.class, e.message]
end
p r.rand == control.rand

def roll(range)
  Random.new(5).rand(range)
end
begin; roll(3.5..1.5); rescue => e; p [e.class, e.message]; end
begin; roll(2.5...2.5); rescue => e; p [e.class, e.message]; end
p roll(2.5..2.5)

r = Random.new(7)
x = r.rand(1.5..3.5)
p [x.class, x >= 1.5 && x <= 3.5]
x = r.rand(1.5...3.5)
p [x.class, x >= 1.5 && x < 3.5]
x = r.rand(1..2.5)
p [x.class, x >= 1 && x <= 2.5]
x = r.rand(1...2.5)
p [x.class, x >= 1 && x < 2.5]
x = r.rand(1.5..3)
p [x.class, x >= 1.5 && x <= 3]
x = r.rand(2..2.0)
p [x.class, x == 2.0]
