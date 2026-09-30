# A reader called on `self`, or on an object a method answers as `self`, reaches
# the `def` a subclass gives the same name, as a receiverless call to it does.
class Base
  attr_reader :h, :sides, :tags, :scale, :flag
  def initialize
    @h = "x"
    @sides = 3
    @tags = [1, 2]
    @scale = 1.5
    @flag = false
    @calls = 0
  end
  def calls = @calls
  def me = self
  def counted
    @calls += 1
    self
  end
  def implicit = h
  def explicit = self.h
  def paren = (self).h
  def safe = self&.h
  def via_me = me.h
  def via_local
    s = self
    s.h
  end
  def via_block = [1].map { self.h }
  def via_lambda = -> { self.h }.call
  def via_counted = counted.h
  def desc = "#{self.h}:#{self.sides}:#{self.tags}:#{self.scale}:#{self.flag}"
  def twice = self.sides * 2
  def same?(other) = other.sides == self.sides
  def cmp = self.h == "y"
  def pair = [self.h, h]
end

class Sub < Base
  def h = "y"
  def sides = 4
  def tags = [9]
  def scale = 2.5
  def flag = true
end

class Deep < Sub
  def h = "deep-" + super
  def sides = super + 2
end

class Plain < Base; end

class Same < Base
  attr_reader :h
end

[Base, Sub, Deep, Plain, Same].each do |k|
  o = k.new
  p [o.implicit, o.explicit, o.paren, o.safe, o.via_me, o.via_local]
  p [o.via_block, o.via_lambda, o.via_counted, o.calls]
  puts o.desc
  p [o.twice, o.cmp, o.pair]
end
p Sub.new.same?(Deep.new)
p Sub.new.same?(Plain.new)

# a value passed on as a method's answer, and a slot holding either class
def answer(o) = o.me.h
p answer(Sub.new)
p answer(Base.new)
box = [Base.new, Sub.new, Deep.new]
p box.map { |o| o.me.h }

# a def of a Struct member in a subclass of the Struct, a reader of a module,
# a reader called with an argument
class Pt < Struct.new(:x, :y)
  def x = 100
  def sum = self.x + self.y
end
p Pt.new(1, 2).sum

module Named
  attr_reader :label
  def show = self.label
end
class Tagged
  include Named
  def initialize = @label = "tagged"
end
class Retagged < Tagged
  def label = "retagged"
end
p Tagged.new.show
p Retagged.new.show

begin
  Sub.new.me.h(1)
rescue ArgumentError => e
  p e.message
end

# a reader read in a loop: an override that runs code runs each time
$k = 0
class Loop1
  attr_reader :items
  def initialize = @items = [1, 2, 3, 4, 5]
  def me = self
  def run
    o = me
    t = 0
    i = 0
    while i < o.items.size
      t += o.items[0]
      i += 1
    end
    t
  end
end
class Loop2 < Loop1
  def items = ($k += 1; [$k] * 5)
end
p Loop1.new.run
p Loop2.new.run

# a def of the original name does not override an alias of the reader
class Aliased
  attr_reader :label
  alias name label
  def initialize = @label = "w"
  def show = self.name
end
class Aliased2 < Aliased
  def label = "l2"
end
p Aliased.new.show
p Aliased2.new.show

# a private or protected override is reached through `self`
class Vis
  attr_reader :v
  def initialize = @v = 1
  def via_self = self.v
end
class VisPrivate < Vis
  private def v = 2
end
class VisProtected < Vis
  protected def v = 3
end
p VisPrivate.new.via_self
p VisProtected.new.via_self
