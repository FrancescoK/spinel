# An inherited hook can be defined on a class by name from outside its body:
# `def Base.inherited(sub)`, or `def inherited` in `class << Base`. It fires
# like one in the body, only for classes created after it, and its `super`
# reaches the hook of an ancestor, or Class#inherited when none has one.

class Base; end
class Early < Base; end
def Base.inherited(k)
  puts "Base got #{k}"
  p super
end
class Late < Base; end
class Deeper < Late; end

class Single; end
class << Single
  def inherited(k) = puts("Single got #{k}")
end
class SingleKid < Single; end

module Outer
  class Inner; end
end
module Outer
  def Inner.inherited(k)
    puts "Inner got #{k}"
    super
  end
end
class InnerKid < Outer::Inner; end

class Top
  def self.inherited(k) = puts("Top got #{k}")
end
class Mid < Top; end
def Mid.inherited(k)
  puts "Mid got #{k}"
  super
end
class Bottom < Mid; end

class Own
  def Own.inherited(k) = puts("Own got #{k}")
end
class OwnKid < Own; end

Point = Struct.new(:x)
def Point.inherited(k) = puts("Point got #{k}")
class Point3 < Point; end
