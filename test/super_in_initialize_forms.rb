# super in initialize as a statement, as initialize's last statement, with
# arguments, and into a Struct's initialize: none of these asks for its
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
p M.new(3).a, L.new.a
p S.new(2).v
