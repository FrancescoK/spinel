# Bool and Symbol have no nil sentinel. A boxed RHS that settles after the
# initial write inference must widen the destination, preserving nil's tag.
x = false
p x == nil
x = (sq = [false]; _, st = *sq; st)
p [x == nil, x, FalseClass === x, NilClass === x]
y = true
y = (tq = [true]; _, tail = *tq; tail)
p [y == nil, y, TrueClass === y, NilClass === y]
z = :value
z = (syms = [:value]; _, missing = *syms; missing)
p [z == nil, z, Symbol === z, NilClass === z]

def optional_symbol(z = nil) = z
class NilSymbolSlot
  def self.a = (@@x = optional_symbol(:value))
  def self.b = (@@x = optional_symbol)
  def self.rd = [:v, :v].zip([:value, @@x])
  def self.check = [Symbol === @@x, @@x == nil, [@@x].include?(nil)]
end
NilSymbolSlot.a
p NilSymbolSlot.rd, NilSymbolSlot.check
NilSymbolSlot.b
p NilSymbolSlot.rd, NilSymbolSlot.check
NilSymbolSlot.a
p NilSymbolSlot.rd
