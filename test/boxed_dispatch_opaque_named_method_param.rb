# A method of the program's named like a call the class-fact analysis does
# not follow (`bind`, `owner`, `receiver`): the call binds nothing, so the
# method's parameters hold anything, and a dispatch on one of them keeps its
# candidates (#8720).
class Tag
  def initialize(label) = @label = label
  def kind = @label
end

class Other
  def kind = :other
end

class Binder
  def bind(x) = x.kind
  def owner(x) = x.kind
  def receiver(x) = x.kind
end

b = Binder.new
p b.bind(Tag.new("a"))
p b.owner(rand < 2 ? Tag.new("b") : Other.new)
p b.receiver(rand < 2 ? Other.new : Tag.new("c"))
