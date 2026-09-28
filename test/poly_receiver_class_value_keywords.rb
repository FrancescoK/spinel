# Keywords into a method called on a value that may be a module (or class)
# rather than an instance. The class-side switch that serves a class value
# was built for positional calls only, so with keywords -- written out or as
# a `**h` -- the module fell through to the instance arms and raised
#
#   undefined method 'draw_machine' for an instance of Class (NoMethodError)
#
# The class-side arms now bind keywords by name as the instance arms do.
module Rend
  def self.draw_machine(m, io: 1) = [:rend, m, io]
  def self.opts(m, **o) = [:rend, m, o]
  def self.pos(m, h = {}) = [:rend, m, h]
  def self.req(m, k:) = [:rend, m, k]
end

class Alt
  def draw_machine(m, io: 0) = [:alt, m, io]
  def opts(m, **o) = [:alt, m, o]
  def pos(m, h = {}) = [:alt, m, h]
  def req(m, k:) = [:alt, m, k]
end

def err
  yield
rescue ArgumentError => e
  e.message
end

class Mm
  attr_writer :r
  def rend = @r || Rend
  def draw(**kw) = rend.draw_machine(1, **kw)
  def draw2 = rend.draw_machine(1, io: 5)
  def draw3(**kw) = rend.draw_machine(1, io: 6, **kw)
  def opts(**kw) = rend.opts(2, **kw)
  def opts_lit = rend.opts(2, a: 1)
  def pos(**kw) = rend.pos(3, **kw)
  def pos_lit = rend.pos(3, b: 2)
  def req(**kw) = rend.req(4, **kw)
end

[nil, Alt.new].each do |r|
  x = Mm.new
  x.r = r
  p x.draw(io: 3)
  p x.draw
  p x.draw2
  p x.draw3
  p x.draw3(io: 8)
  p x.opts(z: 1)
  p x.opts
  p x.opts_lit
  p x.pos(c: 1)
  p x.pos_lit
  p x.req(k: 2)
  p err { x.req }
  p err { x.draw(bad: 1) }
end
