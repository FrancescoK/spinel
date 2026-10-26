# defined?(@x) answers "instance-variable" once an attr_writer or
# attr_accessor of the class, a superclass or an included module has
# stored it, and nil before. A Struct member is no ivar.
class Parser
  attr_writer :version
  def version = (defined?(@version) && @version) || "none"
  def asked = defined?(@version)
end

class Box
  attr_accessor :item
  def has_item? = !defined?(@item).nil?
end

class Never
  attr_reader :gone
  def asked = defined?(@gone)
end

class Sub < Parser
end

p Parser.new.asked
p Parser.new.version
pr = Parser.new
pr.version = "3.0"
p pr.version, pr.asked
pr.version = nil
p pr.asked
s = Sub.new
p s.asked
s.version = "4.1"
p s.version
b = Box.new
p b.has_item?
b.item = 7
p b.has_item?
p Never.new.asked

Pt = Struct.new(:a) do
  def asked = defined?(@a)
end
class Late
  attr_writer :x
  def initialize(x) = (@x = x if x)
  def asked = defined?(@x)
end
p Pt.new(1).asked
p Late.new(nil).asked, Late.new(2).asked
l = Late.new(nil); l.x = 5; p l.asked

module Named
  attr_writer :label
end
class Tag
  include Named
  def asked = defined?(@label)
end
P3 = Struct.new(:a) do
  attr_writer :extra
  def asked = [defined?(@a), defined?(@extra)]
end
t = Tag.new
p t.asked
t.label = "x"
p t.asked
q = P3.new(1)
p q.asked
q.extra = 2
p q.asked
