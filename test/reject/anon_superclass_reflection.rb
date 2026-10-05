# A class whose superclass is an anonymous class has no class object for that
# anonymous class in spinel: `superclass` answered Base (or Struct, or
# Object) where CRuby answers the anonymous class, and `ancestors` left it
# out. Asking is refused.
class Base
end

class FromAnon < Class.new(Base)
end

p FromAnon.superclass
