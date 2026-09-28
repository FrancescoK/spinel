# A splat beside keywords, `e.can_fire?(obj, *args, **kwargs)`, into a method
# called on a value of more than one class was refused at compile time:
#
#   unsupported a splat before other arguments, or beside keywords, into a
#   method called on a value of more than one type
#
# The arms spread the array as before and bind the keywords by name when the
# method takes keywords; a method taking none receives them as one more
# positional Hash when there are any, and not at all when there are none. A
# Proc or Method in the slot, where a user class also defines `call`, gets the
# whole list spread the way a call no user `call` shadows does.
class Ev
  def can_fire?(obj, req = {}) = [:ev, obj, req]
  def kw(a, *r, k: 1) = [:ev, a, r, k]
  def kwr(a, b = 2, k: 1, **o) = [:ev, a, b, k, o]
  def rk(a, k:) = [:ev, a, k]
  def one(a) = [:ev, a]
end

class Ev2
  def can_fire?(obj, req = {}) = [:two, obj, req]
  def kw(a, *r, k: 2) = [:two, a, r, k]
  def kwr(a, b = 3, k: 2, **o) = [:two, a, b, k, o]
  def rk(a, k:) = [:two, a, k]
  def one(a) = [:two, a]
end

def err
  yield
rescue ArgumentError => e
  e.message
end

def helper(e, obj, *args, **kwargs) = e.can_fire?(obj, *args, **kwargs)
def lit(e, obj, *args) = e.can_fire?(obj, *args, z: 1)
def kw(e, *args, **kwargs) = e.kw(*args, **kwargs)
def kwr(e, a, *args, **kwargs) = e.kwr(a, *args, **kwargs)
def rk(e, *args, **kwargs) = e.rk(*args, **kwargs)
def one(e, *args, **kwargs) = e.one(*args, **kwargs)

[Ev.new, Ev2.new].each do |e|
  p helper(e, 1)
  p helper(e, 1, {a: 1})
  p helper(e, 1, b: 2)
  p err { helper(e, 1, {a: 1}, b: 2) }
  p lit(e, 1)
  p kw(e, 1, 2, 3, k: 9)
  p kw(e, 1)
  p kwr(e, 1, 5, k: 0, q: 1)
  p kwr(e, 1)
  p rk(e, 1, k: 4)
  p err { rk(e, 1) }
  p err { kw(e, 1, j: 1) }
  p one(e, 1)
  p err { one(e, 1, x: 1) }
end

# a boxed callable in a Hash of Hashes, beside a user class defining `call`
class Cb
  def call(m, obj, *args) = [:cb, obj, args]
end

class Machine
  def initialize(cb)
    @h = { a: { k: cb } }
  end

  def helper(m, obj, *args) = [:meth, obj, args]
  def run(obj, *args, **kw) = @h.fetch(:a).fetch(:k).call(self, obj, *args, **kw)
end

pr = proc { |m, obj, *args| [:proc, obj, args] }
p Machine.new(pr).run(1)
p Machine.new(pr).run(1, 2, x: 3)
p Machine.new(Cb.new).run(1, 2, x: 3)
p Machine.new(Cb.new).run(1)
mm = Machine.new(nil)
p Machine.new(mm.method(:helper)).run(5, 6)
p Machine.new(mm.method(:helper)).run(5, y: 1)
