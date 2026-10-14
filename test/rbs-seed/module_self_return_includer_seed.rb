# A module's method that answers `self`, declared to return the class that
# includes the module: `self` there is that class's object, and the seed
# holds. It was refused as a contradiction ("declared to return Gadget but
# this returns Widget"), since #9086 kept the seed beside an untyped
# parameter (#9161).
module Widget
  def attach(part = nil)
    return unless part
    self
  end

  class Gadget
    include Widget

    def initialize(part)
      attach(part)
    end
  end
end

g = Widget::Gadget.new(1)
p g.attach(2).nil?
p g.attach.nil?
p g.attach(3).equal?(g)
