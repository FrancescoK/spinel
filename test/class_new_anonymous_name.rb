# spinel: share
# spinel: gc-minor
# Class.new acquires a shared public name when a constant assignment executes.
class NameBase
  def self.label = name
end
first = Class.new(NameBase)
p first.name, first.label
p first.to_s.start_with?("#<Class:0x"), first.inspect.start_with?("#<Class:0x")
NamedFirst = first
p first.name, NamedFirst.name, first.to_s
SecondAlias = first
p first.name
second = Class.new(NameBase) { def answer = 42 }
p second.name, second.new.class.name
NamedSecond = second
p second.name, second.new.answer
NamedDirect = Class.new(NameBase) { p name }
p NamedDirect.name

module NameSpace; end
third = Class.new(NameBase)
p third.name
NameSpace::Named = third
p third.name, NameSpace::Named.name
module NameSpace
  Fourth = Class.new(NameBase)
  Alias = Fourth
  p Fourth.name, Alias.name
end
