# Concrete operator overrides record their actual method without imposing
# the builtin Boolean answer.
class Truth
  def ==(other) = 17
  def !=(other) = 23
  def ! = :negative
end
value = Truth.new
p(value == value)
p(value != value)
p(!value)
