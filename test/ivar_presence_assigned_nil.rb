# spinel: share
# spinel: gc-stress
# An ivar is an instance variable once it is assigned, nil included, and not
# before: instance_variables, instance_variable_defined?, defined?(@x), the
# default inspect (of the object, inside a container or another object's
# ivar) and Marshal.dump leave out one never assigned and show one assigned
# nil, whichever way it was assigned. dup and clone keep what is assigned.

def show(o) = o.inspect.gsub(/0x\h+/, "0x")

class Person
  def initialize(name) = (@name = name)
  def nickname = @nickname
  def nickname=(v)
    @nickname = v
  end
end
pr = Person.new("Ann")
p pr.instance_variables, pr.instance_variable_defined?(:@nickname)
puts show(pr)
pr.nickname = nil
p pr.instance_variables, pr.instance_variable_defined?(:@nickname)
puts show(pr)

class N
  def initialize = (@x = 1)
  def put = (@y = nil)
  def y_defined = defined?(@y)
end
n = N.new
p n.instance_variables, n.instance_variable_defined?(:@y), n.y_defined
p Marshal.dump(n), Marshal.load(Marshal.dump(n)).instance_variables
p n.dup.instance_variables, n.clone.instance_variables
puts show([n]), show({k: n})
n.put
p n.instance_variables, n.instance_variable_defined?(:@y), n.y_defined
p Marshal.dump(n), Marshal.load(Marshal.dump(n)).instance_variables
p n.dup.instance_variables, n.clone.instance_variables
puts show([n]), show({k: n})

# through another object's ivar
class Holder
  def initialize(n) = (@n = n)
end
puts show(Holder.new(N.new))

# every kind of write
class W
  attr_accessor :a
  attr_writer :b
  def initialize(k) = (@k = k)
  def multi
    @p, @q = nil, 1
  end
  def memo = (@r ||= (@k > 5 ? 1 : nil))
  def keep
    @s &&= 1
    nil
  end
  def bits
    @t = nil if @k > 5
    @t |= false
  end
  def chain = (@u = @v = nil)
  def by_name = instance_variable_set(:@w, nil)
end
w = W.new(1)
p w.instance_variables
w.a = nil
p w.instance_variables.sort
x = (w.b = nil)
p x, w.instance_variables.sort
w.multi
p w.instance_variables.sort
p w.memo, w.instance_variables.sort
w.keep
p w.instance_variables.sort
w.bits
p w.instance_variables.sort
w.chain
p w.instance_variables.sort
w.by_name
p w.instance_variables.sort
w2 = W.new(2)
w2.a ||= nil
p w2.instance_variables.sort
w2.a, w2.b = nil, nil
p w2.instance_variables.sort

# a parent's and a module's writes into a subclass instance
module Tagged
  def tag!(t)
    @tag = t
  end
end
class Base
  include Tagged
  def initialize(a) = (@a = a)
  def set_b(v)
    @b = v
  end
end
class Kid < Base
  def initialize(a, c)
    super(a)
    @c = c
  end
end
k = Kid.new(1, nil)
p k.instance_variables.sort
k.set_b(nil)
k.tag!(nil)
p k.instance_variables.sort, k.instance_variable_defined?(:@tag)

# a read inside initialize, before the assignment, finds it unassigned
class Early
  attr_writer :w
  def initialize
    p instance_variables, defined?(@x)
    report
    @x = 1
  end
  def report = p(instance_variable_defined?(:@x))
end
p Early.new.instance_variables

# an object held in a boxed ivar is reached through inspect
class Aa
  def initialize = (@a = 1)
  def setb(v)
    @b = v
  end
end
class Bb
  def initialize = (@c = 2)
  def setd(v)
    @d = v
  end
end
class Box
  def put(o) = (@o = o)
end
aa = Aa.new
bb = Bb.new
h1 = Box.new
h1.put(aa)
h2 = Box.new
h2.put(bb)
puts show(h1), show(h2)
aa.setb(nil)
puts show(h1)

# a hook a subclass overrides, called from the parent's initialize
class Par
  def initialize
    hook
    @x = 1
  end
  def hook = nil
end
class Chi < Par
  def hook = p(instance_variables)
end
p Chi.new.instance_variables

# a subclass's inspect that runs the program's own through super
class Ui
  def initialize = (@a = 1)
  def setb(v)
    @b = v
  end
  def inspect = "Ui"
end
class Vi < Ui
  def inspect = super + "!"
end
vi = Vi.new
vi.setb(nil)
p vi

# writes inside instance_eval and instance_exec blocks, and a class_eval'd method
class Ie
  def initialize = (@a = 1)
  def run(o) = o.instance_eval { @z = nil }
end
Ie.class_eval do
  def put(v) = (@q = v)
end
ie = Ie.new
p ie.instance_variables
ie.instance_eval { @n = nil }
p ie.instance_variables, ie.instance_variable_defined?(:@n)
ie2 = Ie.new
ie2.instance_exec(2) { |v| @m = v }
p ie2.instance_variables
ie3 = Ie.new
ie4 = Ie.new
ie3.run(ie4)
p ie3.instance_variables, ie4.instance_variables
ie5 = Ie.new
ie5.put(nil)
p ie5.instance_variables

# ... also when it is stored from initialize's parameter
class Hold
  def initialize(o) = (@o = o)
end
ca = Aa.new
cb = Bb.new
puts show(Hold.new(ca)), show(Hold.new(cb))
ca.setb(nil)
puts show(Hold.new(ca))

# a super that runs an included module's initialize, not the parent's
class Pm
  def initialize
    @x = 1
    @y = 2
  end
end
module Mi
  def initialize = (@y = 3)
end
class Km < Pm
  include Mi
  def initialize = super
end
km = Km.new
p km.instance_variable_defined?(:@x), km.instance_variable_defined?(:@y), km.instance_variables
puts show(km)

# a default of an optional parameter, or of an optional keyword, runs before
# the body's assignments, and sees the object without them
class Dp
  def show = instance_variables
  def initialize(x = show)
    @a = 1
    p x
  end
end
class Dk
  def show = instance_variables
  def initialize(k: show, j: 1)
    @a = 1
    @b = nil
    p k
  end
end
class Dq
  def initialize(x = 5)
    @a = x
  end
end
Dp.new
Dk.new
p Dq.new.instance_variables
p Dp.new(0).instance_variables, Dk.new(k: 1).instance_variable_defined?(:@a)
