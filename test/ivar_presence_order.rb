# spinel: share
# spinel: gc-stress
# An object lists its ivars in the order they were first assigned:
# instance_variables, the default inspect, Marshal.dump (and so the order
# Marshal.load assigns them in). Assigning an ivar again keeps its place;
# remove_instance_variable takes it out and a later assignment puts it last;
# dup and clone keep the order.

def show(o) = o.inspect.gsub(/0x\h+/, "0x")

class O
  attr_writer :x, :y
  attr_accessor :z
end
o = O.new
o.y = 2
o.x = 1
p o.instance_variables
puts show(o)
o.y = 5
p o.instance_variables
o.z = nil
p o.instance_variables
puts show(o)

# the order a method assigns them in differs between objects
class Q
  def initialize(first)
    @a = 1
    @b = 2 if first
    @c = 3
    @b = 4 unless first
  end
  def late(v)
    @d = v
    @e = nil
  end
  def put_e = (@e = 6)
end
q1 = Q.new(true)
q2 = Q.new(false)
p q1.instance_variables, q2.instance_variables
puts show(q1), show(q2)
q1.late(nil)
q2.put_e
p q1.instance_variables, q2.instance_variables
puts show(q1), show(q2)
q2.late(7)
puts show(q2)

# removing one and assigning it again puts it last
q1.remove_instance_variable(:@a)
p q1.instance_variables
q1.instance_variable_set(:@a, 9)
p q1.instance_variables
puts show(q1)
q1.remove_instance_variable(:@e)
q1.put_e
p q1.instance_variables

# dup and clone keep the order, and what they assign next comes last
d = q2.dup
c = q2.clone
p d.instance_variables, c.instance_variables
d.remove_instance_variable(:@b)
d.instance_variable_set(:@b, 0)
p d.instance_variables, q2.instance_variables

# Marshal writes them in order, and loads them in that order
dumped = Marshal.dump(o)
p dumped
back = Marshal.load(dumped)
p back.instance_variables
s = Marshal.dump(q1)
p s
l = Marshal.load(s)
p l.instance_variables
l.put_e
p l.instance_variables
puts show([o, q2])

# a parent's methods, a subclass's and a module's
module Tag
  def tag(v)
    @tag = v
  end
end
class Base
  include Tag
  def set_b(v)
    @b = v
  end
  def set_a(v)
    @a = v
  end
end
class Kid < Base
  def set_c(v)
    @c = v
  end
end
k1 = Kid.new
k1.set_c(1)
k1.tag(nil)
k1.set_b(2)
p k1.instance_variables
k2 = Kid.new
k2.set_b(1)
k2.set_c(nil)
k2.set_a(3)
p k2.instance_variables
b = Base.new
b.tag(1)
b.set_a(2)
p b.instance_variables
puts show([k1, k2, b])

# a boxed receiver, ops, a multiple assignment and a read of the order
class Z
  def initialize(n)
    @n = n
  end
  def go
    @r ||= 5
    @s, @t = 1, 2
    @u = @s + @t
  end
  def back
    @t = 0
    @s = 0
  end
end
zs = [Z.new(1), O.new]
zs[0].go
zs[1].z = 1
zs[1].x = 2
zs.each { |z| p z.instance_variables }
z2 = Z.new(2)
z2.back
z2.go
p z2.instance_variables

# a rank counter that runs out: more than 65,535 first assignments on one
# object, each after a removal, keep the order
class Cy
  def initialize(f)
    @a = 1 if f
    @b = 2
    @c = 3
  end
  def cycle(i)
    if i % 3 == 0
      remove_instance_variable(:@a)
      @a = i
    elsif i % 3 == 1
      remove_instance_variable(:@b)
      @b = i
    else
      remove_instance_variable(:@c)
      @c = i
    end
  end
end
cy = Cy.new(true)
other = Cy.new(true)
70_000.times { |i| cy.cycle(i) }
p cy.instance_variables, cy.inspect.gsub(/0x\h+/, "0x"), other.instance_variables
cy.cycle(70_000)
p cy.instance_variables
p Marshal.load(Marshal.dump(cy)).instance_variables
cy2 = cy.dup
65_536.times { |i| cy2.cycle(i + 1) }
p cy2.instance_variables, cy.instance_variables

# an abstract base without ivars, and a subclass of its subclass
class Ab
end
class Ik < Ab
  def set_b(v) = (@b = v)
  def set_a(v) = (@a = v)
end
class Il < Ik
  def set_c(v) = (@c = v)
end
il = Il.new
il.set_c(nil)
il.set_a(1)
il.set_b(2)
ik = Ik.new
ik.set_b(nil)
p il.instance_variables, ik.instance_variables, Ab.new.instance_variables
puts show(il), show(Ab.new)

# a listing through a receiver typed as the parent of a ranked family
class Pw
  attr_writer :x, :y
  def list = instance_variables
end
class Qw < Pw
  attr_writer :z
end
qw = Qw.new
qw.z = 1; qw.y = 2; qw.x = 3
pw = Pw.new
pw.y = 1; pw.x = 0
def lw(o) = o.instance_variables
p qw.instance_variables, qw.list, pw.list, lw(pw), lw(qw)
