# Protocol calls retain their user target and its precedence over a fallback.
class Ordered
  include Comparable
  def <=>(other) = 0
end
class Equal
  def ==(other) = false
end
class Both
  include Comparable
  def ==(other) = false
  def <=>(other) = 0
end
a = Ordered.new
b = Ordered.new
p a == b, a != b, a < b, a <= b, a > b, a >= b, a === b
x = Equal.new
p x != Equal.new, x === Equal.new
z = Both.new
p z == Both.new, z != Both.new, z === Both.new

# Truthiness belongs to Ruby even when equality returns a non-Boolean.
class NumericAnswer
  include Comparable
  def ==(other) = 0
  def <=>(other) = 1
end
class SymbolAnswer
  include Comparable
  def ==(other) = :truth
  def <=>(other) = 1
end
class NilAnswer
  include Comparable
  def ==(other) = nil
  def <=>(other) = 0
end
p NumericAnswer.new != NumericAnswer.new
p SymbolAnswer.new != SymbolAnswer.new
p NilAnswer.new != NilAnswer.new

# A boxed operand takes the same delegated protocol.
def unequal(value)
  NumericAnswer.new != value
end
p unequal(NumericAnswer.new), unequal(1)
class OptionalAnswer
  include Comparable
  def initialize(value)
    @value = value
  end
  def ==(other) = @value
  def <=>(other) = 0
end
p OptionalAnswer.new(nil) != OptionalAnswer.new(0)
p OptionalAnswer.new(0) != OptionalAnswer.new(nil)
p unequal(+"x")
a = NumericAnswer.new
p a != a
class BooleanBase
  include Comparable
  def ==(other) = false
  def <=>(other) = 0
  def different(other) = self != other
end
class NumericChild < BooleanBase
  def ==(other) = 0
end
p BooleanBase.new.different(BooleanBase.new)
p NumericChild.new.different(BooleanBase.new)
# Alias resolution retains the protocol's name as well as its user target.
class AliasedAnswer
  include Comparable
  def answer(other) = 0
  alias == answer
  def order(other) = 1
  alias <=> order
end
p AliasedAnswer.new != AliasedAnswer.new
class AliasedAnswer
  def different(other) = self != other
end
class AliasedChild < AliasedAnswer
  def own_answer(other) = false
  alias == own_answer
end
p AliasedAnswer.new.different(AliasedAnswer.new)
p AliasedChild.new.different(AliasedAnswer.new)
# A typed equality must preserve the operand accepted by boxed callbacks.
class EqualAll
  include Comparable
  def <=>(other) = 0
end
x = EqualAll.new
p x == EqualAll.new
[EqualAll.new, Object.new].each { |value| p value == :anything }
# The delegated method still checks its own arity.
class ZeroEquality
  def ==() = 0
end
begin
  p ZeroEquality.new != Object.new
rescue ArgumentError
  puts "arity"
end
