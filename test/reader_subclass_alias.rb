# Subclass aliases still dispatch when no shared mutation needs a handle.
class Parent
  attr_reader :name
  def initialize = (@name = +"name")
  def change
    s = name
    s
  end
end
class MethodAlias < Parent
  def other = (@name + "other")
  alias_method :name, :other
end
class SyntaxAlias < Parent
  def other = (@name + "alias")
  alias name other
end
x = MethodAlias.new
p [x.change, x.instance_variable_get(:@name)]
x = SyntaxAlias.new
p [x.change, x.instance_variable_get(:@name)]
