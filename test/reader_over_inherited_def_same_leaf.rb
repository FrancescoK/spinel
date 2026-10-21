# A reader over a method an ancestor defines, in a program where several
# classes share a leaf name and one Base is a subclass of another Base.
# The walk up the chain went by leaf names with no record of where it had
# been, so Base led back to every Base and the compile did not finish for
# a reader whose name only an unrelated class defines (`count`).

class Top
  class Base
    def label = "top"
    def describe = "<#{label}>"
  end
end
module M1; class Base < Top::Base; end; end
module M2; class Base < Top::Base; end; end
module M3; class Base < Top::Base; end; end

class Tally
  def count = 0
end

class Leaf < M1::Base
  attr_reader :label, :count
  def initialize(label) = (@label = label; @count = 3)
end
p Leaf.new("leaf").describe
p Leaf.new("leaf").count
p Tally.new.count
p M2::Base.new.describe

# Two classes named Item: only one defines `label`.
module A
  class Item
    def label = "A::Item"
    def show = label
  end
end
module B
  class Item
    def show = "B::Item shows #{name}"
    def name = "item"
  end
end
class Box < B::Item
  attr_reader :label, :name
  def initialize(label) = (@label = label; @name = "box")
end
class Crate < A::Item
  attr_reader :label
  def initialize(label) = @label = label
end
p Box.new("box").show
p Box.new("box").label
p Crate.new("crate").show
p A::Item.new.show

# A superclass named through another class's namespace: Holder::Shape is
# Outer::Shape, which Holder inherits.
class Outer
  class Shape
    def kind = "shape"
    def tell = "a #{kind}"
  end
end
class Holder < Outer; end
class Square < Holder::Shape
  attr_reader :kind
  def initialize = @kind = "square"
end
p Square.new.tell

# A module an include names, one of two of the same leaf.
module Named
  module Greet
    def who = "nobody"
    def greet = "hi #{who}"
  end
end
module Greet; end
class Person
  include Named::Greet
  attr_reader :who
  def initialize(who) = @who = who
end
p Person.new("ann").greet
