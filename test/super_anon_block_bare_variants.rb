# super hands the method's block to a parent that keeps it as `&handler`,
# whether the block is a literal, a `&proc`, or absent.
class Base
  def on(tag, &handler)
    @tag = tag
    @handler = handler
  end
  def fire(v) = @handler ? @handler.call(@tag, v) : "no handler for #{@tag}"
end

class Bare < Base
  def on(tag, &) = super
end
class Explicit < Base
  def on(tag, &) = super(tag, &)
end
class Implicit < Base
  def on(tag, &) = super(tag)
end
class Named < Base
  def on(tag, &blk) = super(tag, &blk)
end
class Called < Base
  def on(tag, &blk)
    blk&.call(tag, 0)
    super
  end
end
class Yielder < Base
  def on(tag)
    yield :setup, 0 if block_given?
    super
  end
end

ba = Bare.new
ba.on(:bare) { |t, v| "#{t}:#{v}" }
puts ba.fire(1)
ex = Explicit.new
ex.on(:explicit) { |t, v| "#{t}:#{v}" }
puts ex.fire(1)
im = Implicit.new
im.on(:implicit) { |t, v| "#{t}:#{v}" }
puts im.fire(1)
na = Named.new
na.on(:named) { |t, v| "#{t}:#{v}" }
puts na.fire(1)
yi = Yielder.new
yi.on(:yielder) { |t, v| "#{t}:#{v}" }
puts yi.fire(1)

# no block at all: the parent sees nil
b = Bare.new
b.on(:none)
puts b.fire(2)
e = Explicit.new
e.on(:none_explicit)
puts e.fire(2)
n = Named.new
n.on(:none_named)
puts n.fire(2)

# a proc passed with &
pr = proc { |t, v| "proc #{t}:#{v * 10}" }
e2 = Explicit.new
e2.on(:p, &pr)
puts e2.fire(3)
n2 = Named.new
n2.on(:pn, &pr)
puts n2.fire(3)
y = Yielder.new
y.on(:py, &pr)
puts y.fire(4)

# the stored block writes the caller's locals
sum = 0
ex2 = Explicit.new
ex2.on(:sum) { |_, v| sum += v }
ex2.fire(3)
ex2.fire(4)
calls = []
ca = Called.new
ca.on(:called) { |t, v| calls << "#{t}#{v}" }
ca.fire(5)
p sum, calls

# poly receivers
[Bare, Explicit, Named].each do |k|
  o = k.new
  o.on(k.name.downcase.to_sym) { |t, v| "poly #{t}:#{v}" }
  puts o.fire(6)
end
