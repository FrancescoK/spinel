# A boxed Array's `map { }` is Array#map even where a class method of the
# same name exists: joining that class method's return into the call's
# result made the result poly, which the builtin iteration does not build,
# and the call raised NoMethodError for the Array.
class Table
  def self.map = @map ||= { 1 => :one }
  def self.select = { 2 => :two }
  def self.size = 99
end

PLANS = { jmp: [:a, :b], nop: :none }.freeze

def mask(plan) = plan.map { |step| step == :a }
def picks(plan) = plan.select { |step| step == :b }

p Table.map
p mask(PLANS[:jmp])
p picks(PLANS[:jmp])
p PLANS[:jmp].size
p Table.size
