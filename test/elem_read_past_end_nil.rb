# A call on an element read past the end of a typed pointer Array (objects,
# Integer rows, Float rows) raises NoMethodError, as on nil (#10281).
class Foo
  attr_reader :x
  def initialize(x) = @x = x
end
a = [Foo.new(1), Foo.new(2)]
begin
  p a[9].x
rescue NoMethodError => e
  puts e.message
end
t = Array.new(3) { [0] }
begin
  t[9] << 1
rescue NoMethodError => e
  puts e.message
end
begin
  p t[9].size
rescue NoMethodError => e
  puts e.message
end
f = Array.new(3) { [0.5] }
begin
  p f[5][0]
rescue NoMethodError => e
  puts e.message
end
p a[1].x, t[2].size, f[0][0]

# a read the loop's test keeps within the Array is an element; one after
# the Array shrank in the pass is the nil past its end
class Pt2
  attr_reader :x
  def initialize(x) = @x = x
end
class Popper
  def initialize(a) = @a = a
  def x = (3.times { @a.pop }; 7)
end
def drain(a) = a.pop

sum = 0
pts = Array.new(4) { |i| Pt2.new(i) }
i = 0
while i < pts.size
  sum += pts[i].x
  i += 1
end
p sum

us = Array.new(3) { |i| Pt2.new(i) }
m = 0
begin
  while m < us.size
    us.pop
    p us[m].x
    m += 1
  end
rescue NoMethodError => e
  puts "pop: #{e.message}"
end

vs = Array.new(3) { |i| Pt2.new(i) }
m = 0
begin
  while m < vs.size
    drain(vs)
    p vs[m].x
    m += 1
  end
rescue NoMethodError => e
  puts "drain: #{e.message}"
end

ws = []
4.times { ws << Popper.new(ws) }
n = 1
begin
  while n < ws.size
    p ws[n].x
    p ws[n].x
    n += 1
  end
rescue NoMethodError => e
  puts "method: #{e.message}"
end

k = -1
rs = [Pt2.new(5)]
while k < rs.size
  p rs[k].x
  k += 1
end
