# An inherited hook from a module the superclass extends, and one in a
# Struct.new block, fire when a subclass is defined.

module Tracking
  def inherited(sub)
    super
    puts "tracked #{sub}"
  end
end

class Base
  extend Tracking
end
class A < Base; end
class B < Base; end

# a class's own hook above a module's: the module's runs first, its super
# reaches the class's
class Root
  def self.inherited(sub)
    super
    puts "root sees #{sub}"
  end
end
module Loud
  def inherited(sub)
    puts "loud sees #{sub}"
    super
  end
end
class Mid < Root
  extend Loud
end
class Leaf < Mid; end

Point = Struct.new(:x, :y) do
  def self.inherited(sub)
    super
    puts "struct hook #{sub}"
  end

  def sum = x + y
end
class P3 < Point
  def z = 3
end
pt = P3.new(1, 2)
p pt.sum
p pt.z

# a module no class extends leaves classes alone
module Unused
  def inherited(sub)
    puts "never #{sub}"
  end
end
class Plain; end
class Other < Plain; end
p Other.superclass
