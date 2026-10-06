# super in initialize as a statement, as initialize's last statement, with
# arguments, as the last statement of a list whose value is thrown away, and
# into a Struct's initialize: none of these asks for its
# value, so none is refused (test/reject/super_init_value.rb is the one that
# does).
class N
  def initialize(k) = (@a = [k])
  def a = @a
end

class M < N
  def initialize(k)
    super
    @b = 1
  end
end

class L < N
  def initialize = super(4)
end

class S < Struct.new(:v)
  def initialize(v)
    super
    @r = v
  end
end
# as the last statement of an if or a begin whose own value is thrown away,
# and in the block of an iterator that ignores the block's value
class K < N
  def initialize(flag)
    if flag
      super(5)
    else
      super(6)
    end
    @c = 1
  end
end

class J < N
  def initialize
    [7].each { |k| super(k) }
    begin
      super(8)
    ensure
      @e = 1
    end
  end
end

p M.new(3).a, L.new.a
p K.new(true).a, K.new(false).a, J.new.a
p S.new(2).v
# `return super` leaves initialize, so new drops its value too
class I < N
  def initialize(flag)
    return super(9) if flag
    return(super(10))
  end
end
p I.new(true).a, I.new(false).a
