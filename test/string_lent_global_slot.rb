# A String instance variable of the top level or of a class method, and a
# global variable, live in C globals, and a parameter the callee appends to
# was lent a temp copy of them instead of the slot, so the append never
# reached the variable. An instance's ivar was lent its own slot (#4378);
# the C global is now lent the same way, through a direct call, a keyword
# and an optional parameter, a top-level method, a class and a module
# method, a block and a lambda, and a yield into a block that appends.
# Each append is 100 bytes, so it cannot land in spare capacity by chance.
# spinel: gc-minor
# spinel: share
def gr(v) = v << "x" * 100
def kw(v:) = v << "k" * 100
def opt(a, v = nil) = v << "o" * 100
def yl(v) = yield(v)

@a = +"a"; gr(@a); p @a.size
@b = +"b"; kw(v: @b); opt(1, @b); p @b.size
@c = +"c"; 2.times { gr(@c) }; p @c.size
@d = +"d"; l = -> { gr(@d) }; l.call; p @d.size
@e = +"e"; yl(@e) { |t| t << "y" * 100 }; p @e.size
def tl = (@f = +"f"; gr(@f); @f.size)
p tl

class K
  def self.gr(v) = v << "q" * 100
  def self.run = (@k = +"k"; gr(@k); yl(@k) { |t| t.concat("z" * 100) }; @k.size)
end
p K.run
module M
  def self.go = (@m = +"m"; gr(@m); @m.size)
end
p M.go

$g = +"g"; gr($g); p $g.size
$h = +"h"; yl($h) { |t| t << "y" * 100 }; kw(v: $h); p $h.size
def gm = (gr($g); $g.size)
p gm

# a frozen String still raises, and the slot survives collections
@fz = "fz".freeze
begin; gr(@fz); rescue FrozenError => e; p e.class; end
p @fz
500.times { |i| @z = +"z#{i}"; gr(@z) }
p @z.size
