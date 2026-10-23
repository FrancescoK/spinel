# The existing shared-copy refusal also covers an Object method's ivar read.
class Object
  def label = @label
end
class Labelled
  def initialize(s) = (@label = s)
end
class OtherLabel
  def label = +"other"
end
s = +"text"
objects = [Labelled.new(s), OtherLabel.new, 5]
labels = [objects[0].label, objects[1].label]
labels[0] << "!"
p labels, s, objects[2].label
