# A buffer parameter a POLY parameter's pull turned into a shared handle
# (#5957) is one the caller has to hand its own String. That pull found a
# call's callee by unique name, so a callee whose name another method also
# defines had no call site: the caller kept a plain local, the call wrapped
# a fresh copy in the handle, and every append stayed in the copy (#6065).
# Each probe below uses a name two methods define. The helper appends LONG,
# which always reallocates.
# spinel: gc-minor
LONG = "." * 100

module Helper
  def self.open_into(io) = (io << "<div>" << LONG; nil)
end
Helper.open_into([]) if ARGV.size > 5   # a second caller makes io POLY

def seen(s) = [s.delete("."), s.size]
def buf = String.new

class Coll
  def initialize(xs) = @xs = xs
  def each = @xs.each { |x| yield x }
end

# class methods on a constant: an optional, several levels, a block over
# receivers of mixed classes
module Rooms
  def self.show_into(io, n, notice = nil)
    Helper.open_into(io)
    io << "room#{n}"
    io << ":" << notice if notice
    nil
  end

  def self.body_into(io, n) = (io << "["; show_into(io, n); io << "]"; nil)

  def self.list_into(io, items)
    Helper.open_into(io)
    items.each { |x| x.each { |y| io << y.to_s } }
    nil
  end
end

module Users   # the control: the same names, no helper
  def self.show_into(io, n, notice = nil) = (io << "user#{n}"; nil)
  def self.body_into(io, n) = (show_into(io, n); nil)
  def self.list_into(io, items) = (items.each { |x| io << x.to_s }; nil)
end

def solo_into(io) = (Helper.open_into(io); io << "solo"; nil)   # a unique name

a = buf; Rooms.show_into(a, 1, "n")
b = buf; Rooms.body_into(b, 2)
c = buf; Rooms.list_into(c, [Coll.new([3, 4]), [5]])
d = buf; Users.show_into(d, 6)
e = buf; solo_into(e)
p seen(a), seen(b), seen(c), seen(d), seen(e)

# an instance method on self, from a base class that lends its slot into an
# override that takes the handle, and on a typed receiver
class Base
  def base_into(io) = (io << "base"; nil)
  def render = (io = buf; base_into(io); io)
end

class Sub < Base
  def base_into(io) = (Helper.open_into(io); io << "sub"; nil)
end
f = buf; Sub.new.base_into(f)
p seen(Base.new.render), seen(Sub.new.render), seen(f)

# a base that takes the value, overridden by one that takes the handle
class VBase
  def vbase_into(io) = (io = io + "?"; nil)
  def render = (io = buf; vbase_into(io); io)
end

class VSub < VBase
  def vbase_into(io) = (Helper.open_into(io); io << "vsub"; nil)
end
p seen(VBase.new.render), seen(VSub.new.render)

# a poly receiver, whose arm for the handle parameter takes the caller's
class Loud
  def poly_into(io) = (Helper.open_into(io); io << "loud"; nil)
end

class Quiet
  def poly_into(io) = nil
end
[Loud.new, Quiet.new].each { |v| io = buf; v.poly_into(io); p seen(io) }

# a module through an include and an extend, an alias, a module function
# under a constant path, and a class value
module Shows
  def inc_into(io) = (Helper.open_into(io); io << "inc"; nil)
  alias_method :al_into, :inc_into
end

class Page
  include Shows
  def render = (io = buf; inc_into(io); io)
end

class Other
  extend Shows
  def self.render = (io = buf; inc_into(io); io)
end

module Outer
  module Inner
    module_function

    def mf_into(io) = (Helper.open_into(io); io << "mf"; nil)
  end
end

class KV
  def self.inc_into(io) = (Helper.open_into(io); io << "k"; nil)
  def go = (io = buf; self.class.inc_into(io); io)
end
g = buf; Outer::Inner.mf_into(g)
h = buf; Page.new.al_into(h)
p seen(Page.new.render), seen(Other.render), seen(g), seen(KV.new.go), seen(h)

# #5957's leftovers: a local that is already the handle (its Array's
# elements are appended to), and a plain local through a gathered call,
# into a POLY parameter of a name two classes define
class GA
  def g(t, *r, **o) = (t << LONG; nil)
end

class GB
  def g(t, *r, **o) = nil
end
GA.new.g([]) if ARGV.size > 5
s = +"x"
arr = [s]
arr.each { |w| w << "#" }
GA.new.g(s)
u = +"u"
GA.new.g(u, *[], **{})
p s.size, arr[0].size, u.size
