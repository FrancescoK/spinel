# Which classes fire an inherited hook, and which `super` in a hook reaches
# Class#inherited, is decided from the program's classes, Structs and modules
# by name: a module reopened after a copy without the hook, several `extend`s
# (the last extended answers first), a class reopened (one call), a hook above
# or below another, a Struct block with `extend`, `class << self`, and a
# module with a hook that no class extends.

module M1
  def inherited(s)
    super
    puts "M1 #{s}"
  end
end
module M1
  def other = 1
end
module M2
  def inherited(s) = puts("M2 #{s}")
end
module Plain; end
class A
  extend Plain
  extend M2, M1
end
class B < A; end
class C
  extend Plain
end
class D < C; end
class A
  class E < A; end
end
module Outer
  class A < ::A; end
end
class B2 < B; end
class B2 < B; end

class X
  def self.inherited(s)
    super
    puts "X #{s}"
  end
end
class Y < X
  def self.inherited(s)
    super
    puts "Y #{s}"
  end
end
class Z < Y; end
class W < Z; end
module Q
  def inherited(s)
    super
    puts "Q #{s}"
  end
end
S1 = Struct.new(:a) do
  extend Q
  def self.inherited(s) = super
end
class T < S1; end
class V < Struct.new(:a); end
class U
  class << self
    def inherited(s)
      super
      puts "U #{s}"
    end
  end
end
class U2 < U; end

module H
  def inherited(s)
    super
    puts "H #{s}"
  end
end
class Base; end
class Mid < Base
  extend H
end
class Leaf < Mid; end
class Other
  extend H
end
class Leaf2 < Other; end
module H2
  def inherited(s)
    super
  end
end
class Only
  extend H2
end
class Only2 < Only; end
class Base2
  def self.inherited(s) = (puts "B2 #{s}")
end
module H3
  def inherited(s)
    super
  end
end
class Ext3 < Base2
  extend H3
end
class Sub3 < Ext3; end
class Ext4
  extend H3
  extend H
end
class Sub4 < Ext4; end

module Late; end
module Late
  def inherited(sub) = puts("late #{sub}")
end
class LateBase
  extend Late
end
class LateSub < LateBase; end
class LateSub2 < LateSub; end

module Unused
  def inherited(sub)
    super
    puts "unused #{sub}"
  end
end
class NoHook; end
class NoHookSub < NoHook; end
