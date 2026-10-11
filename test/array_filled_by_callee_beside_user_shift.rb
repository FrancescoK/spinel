# An empty [] a helper fills through its parameter's `<<`, in a program that
# also defines a `<<` of its own.
class Log
  def initialize = @lines = []

  def <<(line)
    @lines.push(line)
    self
  end

  def size = @lines.size
end

class Meth
  attr_reader :name, :singleton

  def initialize(name, singleton)
    @name = name
    @singleton = singleton
  end
end

class Const
  attr_reader :name
  attr_accessor :is_alias_for

  def initialize(name)
    @name = name
    @is_alias_for = nil
  end
end

class Context
  attr_reader :method_list, :constants

  def initialize
    @method_list = []
    @constants = []
    @document_self = true
  end

  def add_to(array, thing)
    array << thing if @document_self
  end

  def add_method(meth) = add_to(@method_list, meth)
  def add_constant(const) = add_to(@constants, const)
end

ctx = Context.new
ctx.add_method Meth.new("new", true)
ctx.add_method Meth.new("each", false)
ctx.add_constant Const.new("X")

class_methods, instance_methods = ctx.method_list.partition { |m| m.singleton }
p class_methods.map(&:name), instance_methods.map(&:name)

ctx.constants.each { |c| c.is_alias_for ||= ctx.method_list.first }
p ctx.constants.map { |c| c.is_alias_for.name }

log = Log.new
log << "a" << "b"
p log.size
