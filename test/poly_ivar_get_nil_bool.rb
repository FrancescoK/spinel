# A boxed getter preserves nil beside Boolean slots and Struct members.
# spinel: infer-ivar-get
S = Struct.new(:flag)
class K
  def initialize(flag)
    @flag = flag
  end
end
p [S.new(1), K.new(false), K.new(true)].map { |o| o.instance_variable_get(:@flag) }
p [K.new(false), 0].map { |o| o.instance_variable_get(:@flag) }
