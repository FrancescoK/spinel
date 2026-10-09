# spinel: reject-subclass: Class.new with a non-constant superclass
class Base; end
base = Base
derived = Class.new(base) {}
p derived.superclass == Base
