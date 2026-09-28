# A block or proc `**k` parameter is a Symbol-keyed kwargs hash, like a
# method's, so it forwards with `**k` into a keyword-rest callee. It holds the
# trailing keywords only: a rest parameter beside it no longer collects them.
class V
  def ignite(*a, **k) = [:ignite, a, k]
end

v = V.new

blk = proc { |o, *a, **k| o.send(:ignite, *a, **k) }
p blk.call(v, 1)
p blk.call(v, 1, x: 2)

blk2 = proc { |o, *a, **k| o.ignite(*a, **k) }
p blk2.call(v, 1)
p blk2.call(v, 1, x: 2)

lam = ->(o, *a, **k) { o.ignite(*a, **k) }
p lam.call(v, 1)
p lam.call(v, 1, x: 2)

def with_yield
  yield(V.new, 1, x: 2)
end
p(with_yield { |o, *a, **k| o.ignite(*a, **k) })

def with_call(&block)
  block.call(V.new, 1, x: 2)
end
p(with_call { |o, *a, **k| o.ignite(*a, **k) })

TARGET = V.new
H = {}
H[:k] = proc { |*a, **k| TARGET.ignite(*a, **k) }
p H[:k].call(1)
p H[:k].call(1, y: 3)

# the state_machines helper shape: a stored block forwarded from a method's
# own splat and double-splat
class Event
  def initialize(name) = @name = name
  def fire(object, *args, **kwargs) = [@name, object, args, kwargs]
end

class Machine
  def initialize
    @helpers = {}
  end

  def event(name) = Event.new(name)

  def define_helper(scope, method, &block)
    @helpers[method] = block
  end

  def aot_call(scope, method, object, *args, **kwargs)
    block = @helpers[method]
    block.call(self, object, *args, **kwargs)
  end
end

machine = Machine.new
name = :ignite
machine.define_helper(:instance, name) { |machine, object, *args, **kwargs| machine.event(name).fire(object, *args, **kwargs) }
p machine.aot_call(:instance, :ignite, :car)
p machine.aot_call(:instance, :ignite, :car, 1, 2)
p machine.aot_call(:instance, :ignite, :car, 1, force: true)

# yielded keywords stay out of the positional parameters
def kw3
  yield(1, 2, b: 3)
end
kw3 { |x, y, z, **k| p [x, y, z, k] }
kw3 { |x, *r, z, **k| p [x, r, z, k] }
kw3 { |x, y = 9, **k| p [x, y, k] }
kw3 { |x, y| p [x, y] }
def kw1
  yield(b: 3)
end
kw1 { |x, **k| p [x, k] }
kw1 { |x, y, **k| p [x, y, k] }
p proc { |a, *r, **k| [a, r, k] }.call(1, 2, x: 3)
p proc { |a, *r, z, **k| [a, r, z, k] }.call(1, 2, 3, x: 3)
