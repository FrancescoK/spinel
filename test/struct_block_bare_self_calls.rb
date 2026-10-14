# In a Struct.new or Data.define block self is the class, held by a constant,
# a local or nothing: a bare call of a Module or Struct method there asks it,
# and the class is anonymous (a local's is never named).
ANON = /\A#<Class:0x\h+>\z/

P = Struct.new(:x) do
  p members, method_defined?(:x), superclass, keyword_init?
  p ancestors.include?(Struct), name
end

k = Struct.new(:x) do
  p members, superclass, name
  p to_s.match?(ANON), "#{self}".match?(ANON)
  p new(1)
end
p k.name, k.new(2), k.to_s.match?(ANON)

d = Data.define(:a) { p [members, name, to_s.match?(ANON)] }
p d.name, d.new(a: 3)

Struct.new(:z) { p [name, members]; p new(1) }
p Struct.new(:w) { p self.inspect.match?(ANON) }.new(5)
