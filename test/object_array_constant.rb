# A constant table of objects narrows
# `PLANETS = [Planet.new(...), ...]` read from methods, and a copy of it
# made with `map(&:dup)`, stayed boxed: a constant had no slot, and a
# copying map was no source. A constant reached by name stays boxed.

class Planet
  attr_accessor :x, :vx
  def initialize(x, vx) = (@x = x; @vx = vx)
end

PLANETS = [Planet.new(1.0, 0.5), Planet.new(2.0, -0.25)]

module Sky
  STARS = [Planet.new(10.0, 0.0), Planet.new(12.5, 0.0)]
  def self.brightest = STARS[1].x
end

def total(ps)
  t = 0.0
  ps.each { |pl| t += pl.x }
  t
end

def advance(ps, dt)
  ps.each { |pl| pl.x += pl.vx * dt }
  nil
end

copy = PLANETS.map(&:dup)
3.times { advance(copy, 0.5) }
p total(PLANETS), total(copy), Sky.brightest, Sky::STARS.size

NAMED = [Planet.new(7.0, 0.0)]
p NAMED[0].x, Object.const_get(:NAMED).size
