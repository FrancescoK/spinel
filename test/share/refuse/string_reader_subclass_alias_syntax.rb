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

class SyntaxAlias < Parent
  def other = (@name + "alias")
  alias name other
end
x = SyntaxAlias.new
p [x.change, x.instance_variable_get(:@name)]
