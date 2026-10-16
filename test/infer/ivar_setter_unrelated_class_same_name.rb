# A setter call reaches the writer of its receiver's class, so it keeps only
# that class's ivar boxed -- not an unrelated class's ivar of the same name.
#
# narrow_object_arrays matched every `x.t = v` against every class's @t without
# resolving the receiver. Ctx#t= called on a Ctx kept State's @t, a table of
# Float rows, a boxed sp_PolyArray; the row it handed Ctx then came out boxed,
# which widened Ctx's @t to an sp_RbVal. Renaming Ctx's ivar made both unboxed.
# State's @t must be an sp_PtrArray and Ctx's @t an sp_FloatArray.
#
# The op-assign forms matched by name the same way: a memoizing `@t ||= x` in
# Memo kept State's @t boxed. One directly in an instance method writes its own
# class's ivar; Memo's @t is an sp_FloatArray and State's narrows regardless.
class Ctx
  attr_accessor :t
  def initialize
    @t = Array.new(0, 0.0)
  end
end

class State
  def initialize(m)
    @t = Array.new(m) { Array.new(1, 0.0) }
  end
  def step(ctx, j)
    v = @t[j]
    ctx.t = v
    ctx.t << 2.0
  end
  def total
    s = 0.0
    j = 0
    while j < @t.length
      s += @t[j][0] + @t[j].length
      j += 1
    end
    s
  end
end

class Memo
  def t
    @t ||= Array.new(1, 1.5)
  end
end

ctx = Ctx.new
st = State.new(4)
st.step(ctx, 1)
p st.total
p ctx.t
p Memo.new.t
