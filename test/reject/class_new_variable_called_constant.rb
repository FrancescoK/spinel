# A lambda held by a constant that is called keeps its variable superclass refused.
# spinel: reject-subclass: Class.new with a non-constant superclass
class Base; end
BUILDER = ->(base) { Class.new(base) {} }
p BUILDER.call(Base).superclass == Base
