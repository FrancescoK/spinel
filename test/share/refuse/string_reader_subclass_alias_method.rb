# spinel: not-cruby
# A subclass alias cannot reuse the ancestor reader handle.
class Parent
  attr_reader :name
  def initialize = (@name = +"name")
  def change
    s = name
    s << "!"
    s
  end
end
class MethodAlias < Parent
  def other = (@name + "other")
  alias_method :name, :other
end

x = MethodAlias.new
p [x.change, x.instance_variable_get(:@name)]
