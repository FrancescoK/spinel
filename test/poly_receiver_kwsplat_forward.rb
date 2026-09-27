# A `**h` passed to a method called on a value of more than one class. The
# dispatch split off a literal keyword list and bound it by name, but a list
# carrying a `**` went through as one more positional argument, so every arm
# raised
#
#   wrong number of arguments (given 2, expected 1) (ArgumentError)
#
# while the same call with `scale: 3` written out worked. Each arm now takes
# its declared keywords out of the hash (the default when absent) and hands
# the rest to a **kwrest, checking missing and unknown keywords as CRuby does.
class Svg
  def render(m, scale: 1) = [:svg, m, scale]
  def opts(m, **o) = [:svg, m, o]
  def both(m, scale: 1, **o) = [:svg, m, scale, o]
  def req(m, scale:) = [:svg, m, scale]
  def plain(m) = [:svg, m]
  def rest(m, *r) = [:svg, m, r]
end

class Dot
  def render(m, scale: 1) = [:dot, m, scale]
  def opts(m, **o) = [:dot, m, o]
  def both(m, scale: 2, **o) = [:dot, m, scale, o]
  def req(m, scale:) = [:dot, m, scale]
  def plain(m) = [:dot, m]
  def rest(m, *r) = [:dot, m, r]
end

def draw(r, **kw) = r.render(:m, **kw)
def draw_lit(r) = r.render(:m, scale: 3)
def draw_before(r, **kw) = r.render(:m, scale: 5, **kw)
def draw_after(r, **kw) = r.render(:m, **kw, scale: 6)
def draw_opts(r, **kw) = r.opts(:m, **kw)
def draw_both(r, **kw) = r.both(:m, extra: 1, **kw)
def draw_req(r, **kw) = r.req(:m, **kw)
def draw_plain(r, **kw) = r.plain(:m, **kw)
def draw_rest(r, **kw) = r.rest(:m, **kw)

def err
  yield
rescue ArgumentError => e
  e.message
end

p draw(Svg.new, scale: 2)
p draw(Dot.new)
p draw_lit(Dot.new)
p draw_lit(Svg.new)
p draw_before(Svg.new)
p draw_before(Dot.new, scale: 7)
p draw_after(Svg.new, scale: 8)
p draw_after(Dot.new)
p draw_opts(Svg.new, a: 1, b: "x")
p draw_opts(Dot.new)
p draw_both(Svg.new, scale: 9, z: :q)
p draw_both(Dot.new)
p draw_req(Svg.new, scale: 4)
p draw_req(Dot.new, scale: 6)
p err { draw_req(Dot.new) }
p err { draw(Svg.new, bogus: 1) }
p draw_plain(Svg.new)
p err { draw_plain(Dot.new, q: 1) }
p draw_rest(Svg.new)
p draw_rest(Dot.new, a: 1)
