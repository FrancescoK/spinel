# defined? of a method call on an object below BasicObject looks the method
# up, as CRuby does: the object has no respond_to? to ask, and Object's
# methods are not its own.
class Blank < BasicObject
  def visible = 1
  attr_reader :r
  def facts = [defined?(freeze), defined?(itself), defined?(visible), defined?(r),
               defined?(self.visible), defined?(hidden)]
  def self.make = new
  private def hidden = 2
end

b = Blank.make
p b.facts
p defined?(b.freeze), defined?(b.visible), defined?(b.equal?(b)), defined?(b.hidden)
