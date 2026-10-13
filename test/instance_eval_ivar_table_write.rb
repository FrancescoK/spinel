# A write into another class's Array-of-Arrays ivar from an instance_eval
# block. The narrowing of the slot to an array of rows (narrow_object_arrays)
# vetted each use by the class of the method it sits in, Poke, so the
# block's write and reads of State's @t went unseen: the slot narrowed under
# a value no conversion keeps there (type inference never converged), and a
# bare reader call in the block pushed a String into the narrowed rows.
class State
  attr_reader :t

  def initialize(m)
    @t = Array.new(m) { Array.new(1, 0.0) }
  end

  def total
    @t[0][0] + @t.length
  end
end

class Other
  def initialize
    @t = [[0.25]]
  end

  def total
    @t[0][0] + @t.length
  end
end

class Poke
  def go(st)
    st.instance_eval { @t = [[1.5], "x"] }
  end

  def push_bare(st)
    st.instance_eval { t << "z" }
  end

  def push_ivar(st)
    st.instance_eval { @t << :w }
  end

  def go_exec(st, v)
    st.instance_exec(v) { |w| @t = [[w], "x", "y"] }
  end
end

s = State.new(3)
Poke.new.go(s)
p s.total

s = State.new(2)
Poke.new.push_bare(s)
Poke.new.push_ivar(s)
p s.total
p s.t.last

s = State.new(2)
Poke.new.go_exec(s, 2.5)
p s.total

# at top level, and over a receiver of either of two classes
s = State.new(2)
s.instance_eval { @t = [[3.5], :q] }
p s.total
[State.new(4), Other.new].each { |q| q.instance_eval { @t = [[4.5], :y, :z] } }
o = Other.new
Poke.new.go(o)
p o.total
