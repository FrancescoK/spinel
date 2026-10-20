# A call on a Class value held boxed looks in the class's singleton class
# first: a class's own `class << self` accessor answers ahead of a class
# method it inherits, a class below it reads its own slot through it, and
# a class method defined below the accessor's class is ahead of it.
class Base
  @@log = []
  def self.label = "base"
  def self.label=(v)
    @@log << v
  end
  def self.log = @@log
end
class Child < Base
  class << self
    attr_accessor :label
  end
end
class Grand < Child
end
class Mid < Child
  def self.label = "mid"
end
class Leaf < Mid
end
class Other < Base
end
Child.label = "child"
[Base, Child, Grand, Mid, Leaf, Other].each do |k|
  p k.label
end
[Base, Child, Grand, Other].each do |k|
  k.label = "set-#{k}"
end
xs = [Base, Child, Grand, Mid, 1]
xs.each do |x|
  p x.label if x.is_a?(Class)
end
p Base.log
