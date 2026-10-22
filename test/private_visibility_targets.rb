# Visibility follows the original receiver through class calls and targets.
class PrivateVisibilityTargets
  attr_reader :v
  private attr_writer :v
  private def []=(key, value)
    @v = value
  end
  protected def protected_value = 7
  public def protected_inside(other) = other.protected_value
  def run
    self.v, other = 2, 3
    p [v, other]
    begin
      other, (self).v = 3, 4
    rescue NoMethodError => e
      puts e.message
    end
    begin
      other, self[:key] = 3, 4
    rescue NoMethodError => e
      puts e.message
    end
    begin
      for self[:key] in [5]; end
    rescue NoMethodError => e
      puts e.message
    end
  end
end
obj = PrivateVisibilityTargets.new
obj.run
p obj.protected_inside(obj)
begin
  obj.protected_value
rescue NoMethodError => e
  puts e.message
end
class PrivateVisibilityTargets
  protected def reopened_protected = 8
  public def reopened_protected_inside(other) = other.reopened_protected
  def reopened
    begin
      (self).v = 6
    rescue NoMethodError => e
      puts e.message
    end
  end
end
obj.reopened
p obj.reopened_protected_inside(obj)
begin
  obj.reopened_protected
rescue NoMethodError => e
  puts e.message
end

def visibility_main_private = 1
begin
  (self).visibility_main_private
rescue NoMethodError => e
  puts e.message
end

# An inherited class method keeps the actual receiver's public override.
class InheritedVisibilityBase
  def self.value = 11
  private_class_method :value
  def self.read = (self).value
end
class InheritedVisibilityPublic < InheritedVisibilityBase
  def self.value = 12
end
p InheritedVisibilityPublic.read
class InheritedVisibilityDeclaredPublic < InheritedVisibilityBase
  public_class_method :value
end
p InheritedVisibilityDeclaredPublic.read

# A public_send on another receiver still names that receiver in the error.
class ExplicitVisibilityHelperTarget
end
begin
  ExplicitVisibilityHelperTarget.new.public_send(:visibility_main_private)
rescue NoMethodError => e
  puts e.message
end

# Parentheses do not deny a protected call from its own class body.
class ProtectedVisibilityBody
  class << self
    protected def value = 21
  end
  p((self).value)
end
class ProtectedVisibilityBody
  p((self).value)
end

class ProtectedVisibilityEval
  protected def value = 22
end
p ProtectedVisibilityEval.new.instance_eval { (self).value }
class ProtectedVisibilityEval
  protected def reopened_value = 23
end
p ProtectedVisibilityEval.new.instance_exec { (self).reopened_value }

# Changing inherited visibility does not require a new method definition.
class InstanceVisibilityBase
  private def x = 24
  def run = (self).x
end
class InstanceVisibilityChild < InstanceVisibilityBase
  public :x
end
p InstanceVisibilityChild.new.run

# Native self keeps the existing dispatch when visibility differs by kind.
require "tmpdir"
class IO
  private def x = 1
  def probe = (self).x
end
class File
  public :x
end
path = File.join(Dir.tmpdir, "spinel_ignvis3_visibility_targets_io")
begin
  File.open(path, "w") { |f| p f.probe }
ensure
  File.unlink(path) if File.exist?(path)
end

class LocalVisibilityTarget
  attr_reader :v
  private attr_writer :v
  def initialize = @v = 0
end
leaf_target = LocalVisibilityTarget.new
begin
  leaf_target.v, other = 1, 2
rescue NoMethodError => e
  puts e.message
end
p leaf_target.v
class LocalVisibilityChild < LocalVisibilityTarget
  public :v=
end
public_target = LocalVisibilityChild.new
public_target.v, other = 3, 4
p public_target.v

class ProtectedPolySelfA
  class << self
    protected def x = 25
  end
end
class ProtectedPolySelfB
  class << self
    protected def x = 26
  end
end
[ProtectedPolySelfA, ProtectedPolySelfB].each do |klass|
  klass.instance_eval { p((self).x) }
end
