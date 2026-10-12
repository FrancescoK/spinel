# A subclass that replaces a reader through `alias` answers its own String
# from the reader's name: the ancestor's method reads it through the
# alias, not the reader's field, while an instance of the ancestor reads
# the field's String itself, so a change through the read shows in the field.
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
y = Parent.new
p [y.change, y.instance_variable_get(:@name)]
