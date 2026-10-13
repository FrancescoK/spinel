# `@t ||= v` in an instance_eval block over another class's object: the slot
# is the receiver's (an Array of Float Arrays, held boxed as a poly array),
# not the enclosing method's class's. The value and statement forms read the
# slot's type from Poke, which has no such ivar, so they took it for a boxed
# value and stored a boxed value into the sp_PolyArray * field: a C compile
# error.
class State
  def initialize(m)
    @t = Array.new(m) { Array.new(1, 0.0) }
  end

  def total
    @t[0][0] + @t.length
  end
end

class Late
  def initialize
    @t = nil
  end

  def total
    @t ? @t[0][0] + @t.length : -1.0
  end
end

class Poke
  def go(st)
    st.instance_eval { @t ||= [[1.5], "x"] }
  end

  def go_stmt(st)
    st.instance_eval { @t ||= [[2.5], "y"]; nil }
  end

  def fill(l)
    l.instance_eval { @t ||= [[1.5], "x"] }
  end
end

s = State.new(3)
Poke.new.go(s)
p s.total
Poke.new.go_stmt(s)
p s.total

l = Late.new
p l.total
Poke.new.fill(l)
p l.total
