# An empty [] a helper fills through its parameter holds what the helper pushes.
class Meth
  attr_reader :name, :singleton
  attr_accessor :visibility
  def initialize(name, singleton)
    @name = name
    @singleton = singleton
    @visibility = nil
  end
end

class Context
  attr_reader :method_list

  def initialize
    @method_list = []
  end

  def add_to(array, thing)
    array << thing
  end

  def add_method(meth)
    add_to @method_list, meth
  end
end

ctx = Context.new
ctx.add_method Meth.new("new", true)
ctx.add_method Meth.new("each", false)
ctx.add_method Meth.new("size", false)

class_methods, instance_methods = ctx.method_list.partition { |m| m.singleton }
p class_methods.map(&:name)
p instance_methods.map(&:name)

pair = ctx.method_list.partition { |m| m.name.start_with?("s") }
p pair.map { |ms| ms.map(&:name) }

ctx.method_list.first.visibility = :private
ctx.method_list.each do |m|
  m.visibility ||= :public
end
p ctx.method_list.map(&:visibility)

# a local, and Integers
def push_to(list, value)
  list.push value
end

nums = []
push_to nums, 3
push_to nums, 4
small, large = nums.partition { |n| n < 4 }
p small, large, nums.sum

# the helper's parameter already typed by another caller's array
class Const
  attr_reader :name
  attr_accessor :is_alias_for

  def initialize(name)
    @name = name
    @is_alias_for = nil
  end
end

class Mod
  attr_reader :attributes, :constants

  def initialize
    @attributes = []
    @constants = []
  end

  def seed(name)
    @attributes << Meth.new(name, false)
  end

  def add_to(array, thing)
    array << thing
  end

  def add_attribute(attr)
    add_to @attributes, attr
  end

  def add_constant(const)
    add_to @constants, const
  end
end

mod = Mod.new
mod.seed "a"
mod.add_attribute Meth.new("b", true)
mod.add_constant Const.new("X")
mod.add_constant Const.new("Y")
mod.constants.first.is_alias_for = Meth.new("Z", false)
mod.constants.each { |c| c.is_alias_for ||= c }
p mod.constants.map { |c| c.is_alias_for.name }
named, others = mod.constants.partition { |c| c.name == "X" }
p named.size, others.map(&:name), mod.attributes.map(&:name)
