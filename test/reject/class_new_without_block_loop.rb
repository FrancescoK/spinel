# A loop must not reuse one static class for a no-block construction.
# spinel: reject-subclass: Class.new(parent)
class NoBlockLoopBase; end
i = 0
while i < 2
  klass = Class.new(NoBlockLoopBase)
  p klass.superclass == NoBlockLoopBase
  i += 1
end
