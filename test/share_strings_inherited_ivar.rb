# A shared ivar has one layout throughout its hierarchy, even in a subclass
# with no access to the ivar of its own. Inherited methods use that layout
# after construction, mutation and replacement of the String.
class Buffer
  def self.raw(data) = data.upcase
  def initialize(data = nil)
    @buf = String.new
    @buf << data if data
    @count = 7
  end
  def update(data)
    @buf << data
    self
  end
  alias << update
  def reset
    @buf = String.new
    self
  end
  def text(data = nil)
    return Buffer.raw(data) if data
    Buffer.raw(@buf)
  end
  def count = @count

  class Child < Buffer
    def initialize(data = nil) = super(data)
    def self.text(data) = data.upcase
  end
  class Sibling < Buffer
  end
end
class Grandchild < Buffer::Child
end
p Buffer::Child.text("hi")
b = Buffer::Child.new("a")
b << "b"
p b.text, b.count
p b.reset.update("c").text
g = Grandchild.new("d")
g << "e"
p g.text, g.count
s = Buffer::Sibling.new("f")
s << "g"
p s.text, s.count

# A descendant can be the mutator; the ancestor and a passive sibling
# still carry the same field. An unrelated class's same-named ivar is local.
class Parent
  def initialize = @buf = +"parent"
  def text = @buf
end
class Mutator < Parent
  def change = @buf << "!"
end
class Observer < Parent
end
m = Mutator.new
m.change
p m.text, Observer.new.text
class Separate
  def initialize = @buf = "separate"
  def text = @buf
end
p Separate.new.text
