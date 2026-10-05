# A Random read from a mixed container keeps its public instance methods.
# Compare bounds and state, since generators need not share CRuby's sequence.
y = [Random.new(1), 1][0]
p y.class
v = y.rand(10)
p v.class
p v >= 0 && v < 10
v = y.rand
p v.class
p v >= 0.0 && v < 1.0
v = y.rand(2.5)
p v.class
p v >= 0.0 && v < 2.5
v = y.rand(3..7)
p v.class
p v >= 3 && v <= 7
v = y.rand(3...7)
p v >= 3 && v < 7
v = y.rand(1.5..2.5)
p v.class
p v >= 1.5 && v <= 2.5
p y.seed
s = y.bytes(12)
p s.class
p s.bytesize
p s.encoding
p y.bytes(0)
p y.bytes(2.9).bytesize
h = {rng: Random.new(7), other: 0}
p h[:rng].seed
p h[:rng].rand(1)
a = [Random.new(9), nil][0]
b = [Random.new(9), false][0]
p a == b
p a.equal?(b)
p a.eql?(b)
a.rand
p a == b
b.rand
p a == b
p a == Random.new(10)
p a == 1
p a == nil

# The bound can itself arrive in a boxed slot.
[10, 2.5, 3..7, 1.5...2.5].each do |bound|
  p y.rand(bound).class
end
[0, -1, -1.5, nil, 5...5, 7..3, "10"].each do |bound|
  begin
    y.rand(bound)
  rescue => e
    p e.class
    puts e.message
  end
end
[-1, "2", nil].each do |count|
  begin
    y.bytes(count)
  rescue => e
    p e.class
    puts e.message
  end
end
begin
  y.rand(1, 2)
rescue => e
  p e.class
end
begin
  y.seed(1)
rescue => e
  p e.class
end

# User methods sharing these names still dispatch to their own receiver.
class RandomNeighbour
  def rand(n = 1)
    0
  end
  def bytes(n)
    "x"
  end
  def seed
    23
  end
end
[Random.new(23), RandomNeighbour.new].each do |r|
  p r.seed
  p r.rand(1)
  p r.bytes(1).bytesize
end
