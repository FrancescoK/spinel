# In a class or module body self is the class, so instance_variable_set and
# instance_variable_get there (bare or on self) reach the class's own ivars,
# as `@x = v` and `@x` do. Also through `base.instance_variable_set` in an
# included hook.
class Base
  class << self
    attr_accessor :flag
  end
  @flag = false
  def flag = self.class.instance_variable_get(:@flag)
end

class Bare < Base
  instance_variable_set(:@flag, :bare)
end

class OnSelf < Base
  self.instance_variable_set(:@flag, :on_self)
  p instance_variable_get(:@flag)
  p self.instance_variable_get(:@flag)
end

class ByString < Base
  instance_variable_set("@flag", :by_string)
  if true
    instance_variable_set(:@count, 1)
  end
  def self.count = @count
end

module Settings
  instance_variable_set(:@level, 3)
  def self.level = @level
end

module Hooked
  def self.included(base)
    base.instance_variable_set(:@flag, :hooked)
  end
end

class WithHook < Base
  include Hooked
end

# a nested class's body is its own
class Outer
  class Inner
    instance_variable_set(:@name, "inner")
    def self.name_ivar = @name
  end
  def self.name_ivar = @name
end

p Base.flag, Bare.flag, OnSelf.flag, ByString.flag, WithHook.flag
p Base.new.flag, Bare.new.flag, WithHook.new.flag
p ByString.count, Settings.level
p Outer::Inner.name_ivar, Outer.name_ivar
