# An explicit proc on super replaces the caller's block and owns the result.
class Parent
  def run = yield
end
class Child < Parent
  def run
    local_proc = proc { "local" }
    super(&local_proc)
  end
end
p Child.new.run
p Child.new.run { 42 }
class Forwarded < Parent
  def run(&block) = super(&block)
end
p Forwarded.new.run { "forwarded" }
class NoBlock < Parent
  def run = super(&nil)
end
begin
  NoBlock.new.run { 42 }
rescue LocalJumpError
  puts "LocalJumpError"
end

# A block_given? tail answers the supplied proc in every spelling.
class IfParent
  def run
    if block_given?
      yield
    else
      1
    end
  end
end
class IfInteger < IfParent
  def run = super(&proc { 42 })
end
if_integer = IfInteger.new.run
p if_integer, if_integer.class
class IfString < IfParent
  def run = super(&proc { "local" })
end
if_string = IfString.new.run
p if_string, if_string.class
class IfNil < IfParent
  def run = super(&proc { nil })
end
if_nil = IfNil.new.run
p if_nil, if_nil.class
class UnlessParent
  def run
    unless block_given?
      1
    else
      yield
    end
  end
end
class UnlessInteger < UnlessParent
  def run = super(&proc { 42 })
end
unless_integer = UnlessInteger.new.run
p unless_integer, unless_integer.class
class UnlessString < UnlessParent
  def run = super(&proc { "local" })
end
unless_string = UnlessString.new.run
p unless_string, unless_string.class
class UnlessNil < UnlessParent
  def run = super(&proc { nil })
end
unless_nil = UnlessNil.new.run
p unless_nil, unless_nil.class
class TernaryParent
  def run
    block_given? ? yield : 1
  end
end
class TernaryInteger < TernaryParent
  def run = super(&proc { 42 })
end
ternary_integer = TernaryInteger.new.run
p ternary_integer, ternary_integer.class
class TernaryString < TernaryParent
  def run = super(&proc { "local" })
end
ternary_string = TernaryString.new.run
p ternary_string, ternary_string.class
class TernaryNil < TernaryParent
  def run = super(&proc { nil })
end
ternary_nil = TernaryNil.new.run
p ternary_nil, ternary_nil.class
