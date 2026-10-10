# spinel: share
# A parameter default that reads a variable holding a String binds that
# String itself, as a passed argument does: a change through the
# parameter, or through what the call answers, reaches the variable.
#
# A lambda's defaults were joined with nothing in the share facts (its
# parameters are not a block's BlockParametersNode), and a block
# inlined at a yield coerced its default into a fresh String: either way
# the parameter was bound to a copy, so `t << "!"` after
# `t = ->(v = s) { v }.call` left s unchanged.

def lam(s)
  d = ->(v = s) { v }
  t = d.call
  t << "!"
  p s.equal?(t), s
end
lam(+"lam")

def lam_kw(s)
  d = ->(v: s) { v }
  t = d.call
  t.force_encoding("ASCII-8BIT")
  p s.equal?(t), s.encoding
end
lam_kw(+"kw")

def lam_inside(s)
  d = ->(v = s) { v << "?" }
  d.call
  d.()
  p s
end
lam_inside(+"in")

def lam_second(s, u)
  d = ->(a = u, b = s) { b.upcase! }
  d.call
  p s, u
end
lam_second(+"two", +"u")

def lam_ivar
  @iv = +"iv"
  d = ->(v = @iv) { v }
  d.call.replace("IV")
  p @iv
end
lam_ivar

def lam_gvar
  $gv = +"gv"
  d = lambda { |v = $gv| v }
  d.call.insert(0, "<")
  p $gv
end
lam_gvar

def lam_fresh(s)
  d = ->(v = +"fresh") { v }
  t = d.call(s)
  t << "!"
  u = d.call
  u << "?"
  p s, u, s.equal?(u)
end
lam_fresh(+"p")

def prc(s)
  d = proc { |v = s| v }
  t = d.call
  t << "!"
  p s.equal?(t), s
end
prc(+"prc")

def prc_kw(s)
  d = proc { |v: s| v }
  t = d.call
  t << "!"
  p s.equal?(t), s
end
prc_kw(+"pkw")

def opt(s, v = s) = v
def opt_kw(s, v: s) = v
def meth(s)
  t = opt(s)
  t << "!"
  u = opt_kw(s)
  u << "?"
  p s.equal?(t), s.equal?(u), s
end
meth(+"meth")

def yl = yield
def blk(s)
  t = yl { |v = s| v }
  t << "!"
  p s.equal?(t), s
end
blk(+"blk")

def blk_kw(s)
  t = yl { |v: s| v }
  t << "!"
  p s.equal?(t), s
end
blk_kw(+"bkw")

def blk_inside(s)
  yl { |v = s| v.concat("+", "+") }
  p s
end
blk_inside(+"bin")
