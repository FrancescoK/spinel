# spinel: reject-subclass: Class.new with a non-constant superclass
class Base; end
base = Base
Derived = Class.new(base)
p Derived.superclass == Base
