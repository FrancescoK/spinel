# spinel: share
# spinel: gc-stress
# A class whose initialize assigns every ivar unconditionally lists them in
# the order it does, not in the order its methods first name them; a super
# stands for the parent's initialize (an included module's, where the class
# has one). The order holds only while nothing before the last assignment
# could assign an ivar first. (No allocate and no Marshal.load here: an
# object they make runs no initialize.)

def show(o) = o.inspect.gsub(/0x\h+/, "0x")

# a class whose initialize assigns every ivar lists them in that order: a
# helper that names one first, or an assignment around super, changes nothing
class Zz
  def helper = @b
  def initialize
    @a = 1
    @b = 2
  end
end
class P3
  def initialize
    @z = 0
  end
end
class C3 < P3
  def initialize
    @w = 1
    super
    @v = 2
  end
end
class P4
  def initialize(a)
    @p, @q = a, 2
  end
end
class C4 < P4
  def initialize
    @m = 0
    super(1)
    @n ||= 3
  end
end
p Zz.new.instance_variables, C3.new.instance_variables, C4.new.instance_variables
puts show(Zz.new), show(C3.new), show(C4.new)
p Marshal.dump(C3.new)
p [C4.new, Zz.new].map(&:instance_variables)

# ... unless something before the last first assignment could assign an ivar
# first: a method it calls, a value that calls one, a block
class K3
  def reset
    @a = 0
    @b = 0
  end
  def initialize
    reset
    @b = 2
    @a = 1
  end
end
class K2
  def build
    @size = 0
    []
  end
  def initialize
    @buf = build
    @size = 1
  end
end
class H5
  def initialize
    [1].each { @a = 0 }
    @b = 2
    @a = 1
  end
end
class H6
  def initialize
    @c = 3
    x = 5
    @d = x
    @e = x + 1
  end
  def above = @e
end
p K3.new.instance_variables, K2.new.instance_variables, H5.new.instance_variables
p H6.new.instance_variables
puts show(K3.new), show(K2.new), show(H5.new)


# a super into an included module's initialize, a super with a block, and a
# parent without ivars
module Mx
  def initialize
    @m = 1
    super
    @mm = 4
  end
end
class Px
  def initialize = (@p = 2)
end
class Kx < Px
  include Mx
  def initialize
    @k = 0
    super
  end
end
class Bx
  def initialize
    super
    @b = [1].size
  end
end
class Ax
  def initialize
    super { @z = 1 }
    @y = 2
  end
  def z = @z
end
class Ab
end
class Cb < Ab
  def initialize
    @q = 1
    @r = 2
  end
  def above = @r
end
p Kx.new.instance_variables, Bx.new.instance_variables, Cb.new.instance_variables
puts show(Kx.new), show(Cb.new)
p Ax.new.instance_variables

# ... nor a parameter's default or an ensure clause; and a listing through a
# receiver typed as the parent follows the order of the object's own class
class Pd
  def setup; @pdb = 0; end
  def initialize(x = setup)
    @pda = 1
    @pdb = 2
  end
end
class Pk
  def setup; @pka = 0; end
  def initialize(k: setup)
    @pkb = 2
    @pka = 1
  end
end
class Pe
  def h = [@pea, @pec, @peb]
  def reset
    @pec = 0
    @peb = 0
  end
  def initialize
    begin
      @pea = 1
    ensure
      reset
    end
    @peb = 2
    @pec = 3
  end
end
class Pp
  def h = [@ppb, @ppa]
  def initialize; @ppa = 1; @ppb = 2; end
  def list = instance_variables
end
class Pc < Pp
  def initialize; @ppb = 0; super; end
end
class Pq < Pp
  def initialize; super; @ppz = 3; end
end
p Pd.new.instance_variables, Pk.new.instance_variables, Pe.new.instance_variables
puts show(Pe.new)
p Pp.new.list, Pc.new.list, Pp.new.instance_variables, Pq.new.list

# a listing through a receiver typed as a parent lists what the object's own
# class does: an ivar a subclass adds, one it leaves unassigned, another order
class Ra
  def initialize; @ra = 1; @rb = 2; end
  def list = instance_variables
  def insp = inspect.gsub(/0x\h+/, "0x")
end
class Rb < Ra
end
class Rc < Rb
  def initialize; @rb = 0; super; @rc = 3; end
end
class Rd < Rb
  def initialize; @rd = 9; end
end
class Re < Rc
  def initialize; @re = 5; super; end
end
class Sq < Rb
  def initialize; super; @sq = 3; end
end
p Ra.new.list, Rb.new.list, Rc.new.list, Rd.new.list, Re.new.list, Sq.new.list
p [Ra.new, Rc.new, Rd.new, Re.new, Sq.new].map(&:insp)
def lister(x) = x.instance_variables
p lister(Ra.new), lister(Rc.new), lister(Rd.new), lister(Re.new), lister(Sq.new)
y = Rb.new
y = Rc.new if ARGV.empty?
p y.instance_variables, y.list
