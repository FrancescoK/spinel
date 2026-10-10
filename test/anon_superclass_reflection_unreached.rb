# `superclass` and `ancestors` that can reach a class whose superclass is
# an anonymous class are refused where codegen emits them: a method nothing
# calls is never emitted, and `defined?` does not call the method.
class Base
end

class FromAnon < Class.new(Base)
  def self.parent_name = superclass.name
end

def chain(k) = k.ancestors

p defined?(FromAnon.superclass)
p FromAnon.name
