# spinel: not-cruby
# Missing-method dispatch is unsupported. Flagged-off self calls retain
# master's answers when a class or ancestor defines method_missing.
class VisibilityMissingBase
  private def x = 1
  def method_missing(name, *args) = "mm:#{name}"
  def respond_to_missing?(name, include_private = false) = true
  def run = (self).x
end
class VisibilityMissingChild < VisibilityMissingBase
end
class VisibilityMissingReopened
  private def x = 2
  def run = (self).x
end
class VisibilityMissingReopened
  def method_missing(name, *args) = "reopen:#{name}"
end
p VisibilityMissingBase.new.run
p VisibilityMissingChild.new.run
p VisibilityMissingReopened.new.run
# A boxed receiver's precheck keeps the same compatibility policy.
class VisibilityMissingBox
  private def x = 3
  def method_missing(name, *args) = "box:#{name}"
  def run
    [self, VisibilityMissingBase.new].each { |item| p item.run_leaf }
  end
  def run_leaf = (self).x
end
class VisibilityMissingBase
  def run_leaf = (self).x
end
VisibilityMissingBox.new.run
puts "done"

class VisibilityMissingClass
  def self.x = 4
  private_class_method :x
  def self.method_missing(name, *args) = "class:#{name}"
  def self.run = (self).x
end
p VisibilityMissingClass.run

class VisibilityMissingClass
  p((self).x)
end

# A hook added only by the actual subclass also preserves master.
class VisibilityMissingParent
  private def x = 8
  def run = (self).x
end
class VisibilityMissingOwnChild < VisibilityMissingParent
  def method_missing(name, *args) = "child:#{name}"
end
p VisibilityMissingOwnChild.new.run

# New target checks also preserve master for an explicit receiver.
class MissingMasgnLocal
  attr_reader :v
  private attr_writer :v
  def initialize = @v = 0
  def method_missing(name, *args) = "mm:#{name}"
end
a = MissingMasgnLocal.new
begin
  a.v, other = 1, 2
  puts "done"
rescue NoMethodError
  puts "error"
end
p a.v

class MissingMasgnChild < MissingMasgnLocal
  def method_missing(name, *args) = "child:#{name}"
end
child_target = MissingMasgnChild.new
child_target.v, other = 3, 4
p child_target.v

# Class-valued rebound self reaches the shared class visibility plan.
class VisibilityMissingPolyA
  def self.x = 10
  private_class_method :x
  def self.method_missing(name, *args) = "mm:#{name}"
end
class VisibilityMissingPolyB
  def self.x = 11
  private_class_method :x
  def self.method_missing(name, *args) = "mm:#{name}"
end
[VisibilityMissingPolyA, VisibilityMissingPolyB].each do |klass|
  klass.instance_eval { p((self).x) }
end
