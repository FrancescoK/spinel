# A reader declared in a reopening of a class stands over a method the
# class's ancestors define, wherever its superclass or the include is
# written: the walk up the chain starts from every header of the class,
# not only the one that declares the reader.

class Shape
  def label = "shape"
  def describe = "<#{label}>"
end

# the superclass on the first header, the reader on a reopening
class Square < Shape; end
class Square
  attr_reader :label
  def initialize = @label = "square"
end
p Square.new.describe

module Tagged
  def tag = "tagged"
  def show = "[#{tag}]"
end

# the include on a later reopening
class Item
  attr_reader :tag
  def initialize = @tag = "item"
end
class Item
  include Tagged
end
p Item.new.show

# the include on an earlier reopening
class Crate
  include Tagged
end
class Crate
  attr_reader :tag
  def initialize = @tag = "crate"
end
p Crate.new.show

p Shape.new.describe
