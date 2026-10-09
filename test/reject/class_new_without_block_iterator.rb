# A block must not reuse one static class for a no-block construction.
# spinel: reject-subclass: Class.new(parent)
class NoBlockIteratorBase; end
2.times do
  klass = Class.new(NoBlockIteratorBase)
  p klass.superclass == NoBlockIteratorBase
end
