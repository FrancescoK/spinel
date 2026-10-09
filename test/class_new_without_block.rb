# spinel: share
# spinel: gc-minor
# Omitting the block still defines the named or anonymous subclass.
class EmptyBlockBase
  def answer = 42
end
EmptyBlockNamed = Class.new(EmptyBlockBase)
p EmptyBlockNamed.superclass == EmptyBlockBase
p EmptyBlockNamed.new.answer
local = Class.new(EmptyBlockBase)
p local.superclass == EmptyBlockBase
p local.new.answer
EmptyBlockChild = Class.new(EmptyBlockNamed)
p EmptyBlockChild.new.answer
