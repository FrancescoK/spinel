# A class defined before its superclass has an inherited hook fires nothing,
# as the hook did not exist when the class was created; one defined after
# fires it, and reopening the early class later fires nothing either. The
# hook can arrive with its own `def`, or with an `extend` of a module that
# has one, and the class can sit inside the body that defines the hook.

class Base
  def self.all = (@all ||= [])
end
class Early < Base; end
class Base
  def self.inherited(k)
    all << k
    super
  end
end
class Late < Base; end
class Early < Base; end
p Base.all

module Tracking
  def inherited(k)
    puts "tracked #{k}"
    super
  end
end
class Tracked; end
class BeforeExtend < Tracked; end
class Tracked
  extend Tracking
end
class AfterExtend < Tracked; end

class Outer
  class Inner1 < Outer; end
  def self.inherited(k) = puts("Outer got #{k}")
  class Inner2 < Outer; end
end

class Grand; end
class Parent < Grand; end
class Child1 < Parent; end
class Grand
  def self.inherited(k) = puts("Grand got #{k}")
end
class Child2 < Parent; end

module LateHook; end
class Host
  extend LateHook
end
class HostEarly < Host; end
module LateHook
  def inherited(k) = puts("LateHook got #{k}")
end
class HostLate < Host; end
