# spinel: reject-subclass: Class.new with a non-constant superclass
class Base; end
base = Base
body = proc {}
Derived = Class.new(base, &body)
p Derived.superclass == Base
