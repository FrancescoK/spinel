# A parameter is narrowed from the call sites the resolution can see. `super`
# is not one of them: it reaches the parent's method of the SAME name with no
# CallNode naming it. For `initialize` that is reachable, because it resolves
# through `K.new` on a constant receiver rather than by unique name -- so the
# only VISIBLE call here is `Holder.new(@col[q])`, an Integer-array element,
# while `Sub#initialize` hands the same parameter a String through `super`.
#
# Narrowed to sp_int on the visible call alone, the emitted C did not compile:
# the super arm passes a const char * to an sp_int parameter. A scope reached
# by super keeps the boxed slot, as do the runtime protocols and an extension
# entry, whose arguments no call site in the program supplies either.
class Holder
  def initialize(v)
    @v = v
  end
  def v
    @v
  end
end

class Sub < Holder
  def initialize(s)
    super(s)
  end
end

class Src
  def initialize
    @col = Array.new(0, 0)
  end
  def add(c)
    @col << c
    0
  end
  def make(q)
    Holder.new(@col[q])
  end
end

s = Src.new
s.add(5)
p s.make(0).v
p Sub.new("text").v

# The same method WITHOUT a super route still narrows: the guard is the route,
# not the shape.
class Plain
  def initialize(v)
    @v = v
  end
  def v
    @v
  end
end

class Mk
  def initialize
    @col = Array.new(0, 0)
  end
  def add(c)
    @col << c
    0
  end
  def make(q)
    Plain.new(@col[q])
  end
end

m = Mk.new
m.add(9)
p m.make(0).v
