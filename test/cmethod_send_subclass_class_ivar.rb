# An inherited class method run on a subclass through send, __send__ or
# public_send reads the subclass's class-level instance variables, as a
# direct call does. The inherited hook is called that way on the
# superclass, so a table each class copies from its parent there builds
# on the parent's own entries.

class Base
  class << self
    attr_accessor :features

    def inherited(subclass)
      super
      subclass.features = features.to_h.map { |k, v| [k, v.dup] }.to_h
    end

    def implements(type, tokens)
      (features[type] ||= []).concat(tokens)
    end

    def tagged(x)
      [name, @tag, x]
    end

    def tag=(v)
      @tag = v
    end
  end
end

class A < Base
  implements :x, [1, 2]
end

class B < A
  implements :x, [3]
  implements :y, [4]
end

p Base.features
p A.features
p B.features

Base.tag = :base
A.tag = :a
B.tag = :b
p A.send(:tagged, 1)
p B.__send__(:tagged, 2)
p A.public_send(:tagged, 3)
