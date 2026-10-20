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

# within one class the later definition answers: the accessor declared
# after `def self.tag`, or the method defined after the accessor
class Early
  def self.tag = "method"
  class << self
    attr_accessor :tag
  end
end
class Late
  class << self
    attr_accessor :tag
  end
  def self.tag = "method"
end
Early.tag = "slot"
[Early, Late, 1].each { |k| p k.tag if k.is_a?(Class) }

# a writer reached through an alias writes, and reads, the slot it names
class Aliased < Base
  class << self
    attr_accessor :mark
    alias_method :other=, :mark=
  end
end
class Plain
  def self.other=(v)
    v
  end
end
k = [Aliased, Plain, 1][ARGV.size]
p(k.other = "x")
p Aliased.mark
