# An inherited hook run for a grandchild runs with the parent as self, so
# the class-level state it reads and writes is the parent's: a chain of
# classes each taking its parent's features (V3 < V2 < V1 < Base).
class Base
  class << self
    attr_accessor :features

    def inherited(sub)
      super
      (@children ||= []) << sub.name
      sub.features = (features || {}).map { |k, v| [k, v.dup] }.to_h
    end

    def implements(type, tokens)
      (features[type] ||= []).concat(tokens)
    end

    def children = @children
  end
  self.features = {}
end

class V1 < Base
  implements :escape, [:a]
end
class V2 < V1
  implements :escape, [:b]
  implements :group, [:x]
end
class V3 < V2
  implements :escape, [:c]
end
class Side < Base; end

p Base.features, V1.features, V2.features, V3.features, Side.features
p Base.children, V1.children, V2.children, V3.children
p V1.send(:children)
