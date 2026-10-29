# A user class named like one of the runtime's C types (sp_StringLiteral,
# sp_SumState, ...) compiles under a name of its own instead of colliding
# with the runtime's typedef.
class StringLiteral
  attr_reader :v
  def initialize(v) = @v = v
end
class SumState
  attr_reader :v
  def initialize(v) = @v = v
end
class EqlSet
  attr_reader :v
  def initialize(v) = @v = v
end
class LoadCand
  attr_reader :v
  def initialize(v) = @v = v
end
class ProcWide
  attr_reader :v
  def initialize(v) = @v = v
end
class EnumStr
  attr_reader :v
  def initialize(v) = @v = v
end
[StringLiteral.new("a"), SumState.new(1), EqlSet.new(:s), LoadCand.new(2.5),
 ProcWide.new(nil), EnumStr.new([1])].each { |o| p [o.class, o.v] }
puts StringLiteral.new("lit").v + "!"
puts SumState.new(41).v + 1
