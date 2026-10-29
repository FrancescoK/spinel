# A table handed to a method of its own elements narrows
# `bodies.each { |b| b.step(bodies) }` calls a method of the element class
# with the table itself. The element is boxed until the table narrows, and
# the call on it killed the table as a dynamic call, so neither the table
# nor the method's parameter narrowed. A block parameter the block
# reassigns is no element, and its call stays dynamic.

class Body
  attr_accessor :x, :v
  def initialize(x, v) = (@x = x; @v = v)

  def step(bodies, dt)
    bodies.each { |o| @v -= (@x - o.x) * dt }
    @x += @v * dt
  end

  def nearest(bodies)
    best = nil
    bodies.each { |o| best = o if !o.equal?(self) && (best.nil? || (o.x - @x).abs < (best.x - @x).abs) }
    best.x.round(6)
  end
end

class Sim
  def initialize = @bodies = [Body.new(0.0, 1.0), Body.new(1.0, 0.5), Body.new(3.0, -0.25)]

  def run(n)
    n.times do
      @bodies.each_with_index { |b, i| b.step(@bodies, 0.01 * (i + 1)) }
    end
  end

  def nearest_to_second = @bodies[1].nearest(@bodies)
  def xs = @bodies.map { |b| b.x.round(6) }
end

s = Sim.new
s.run(100)
p s.xs, s.nearest_to_second

class Rod
  attr_reader :len
  def initialize(len) = @len = len
  def advance(rods) = rods.size * @len
end

class Probe
  def advance(rods) = -rods.size
end

rods = [Rod.new(1.5), Rod.new(4.0)]
rods.each do |r|
  r = Probe.new if r.len > 2.0
  p r.advance(rods)
end
