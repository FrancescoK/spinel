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
