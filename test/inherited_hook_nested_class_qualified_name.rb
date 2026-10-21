# An inherited hook on one Base does not fire for a class whose superclass
# is another class under another Base, when that class is defined in the
# body of a class that has a superclass. Its superclass was then left to
# the leaf names, as if the ancestors of the class around it could supply
# the name, and Shapes::Line was sent the hook it does not have.

module Hooks
  LOG = []
  class Base
    def self.inherited(sub)
      LOG << sub.name
      super
    end
  end
  class Plain < Base; end
end

module Shapes
  class Base; end
  class Line < Shapes::Base; end
  class Group < Shapes::Base
    class Segment < Shapes::Line; end
    class Stroke < Line; end
    class Marked < Hooks::Base; end
  end
end

module Shapes
  class Ring < Shapes::Base
    class Arc < ::Shapes::Line; end
  end
end

# at the top level, the name is found at the top level: no class or
# module holds a Shapes or a Hooks of its own
class Figure < Shapes::Base
  class Edge < Shapes::Line; end
  class Tag < Hooks::Base; end
end

p Shapes::Group::Segment.superclass
p Shapes::Group::Stroke.superclass
p Shapes::Ring::Arc.superclass
p Figure::Edge.superclass
p Figure::Tag.superclass

p Hooks::LOG
