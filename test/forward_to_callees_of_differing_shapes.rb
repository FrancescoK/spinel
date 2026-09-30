# `...` forwarded to a method whose same-named definitions take different
# parameter channels -- none, positional, optional, keywords, a block -- goes
# through the positional, keyword and block channels together: an empty
# splat passes nothing, so each callee still sees exactly what was passed.
class N1
  def start(name, id) = "n1 #{name} #{id}"
end
class N2
  def start(name, id, payload = nil) = "n2 #{name} #{id} #{payload.inspect}"
end
class N3
  def start(name, at: 0) = "n3 #{name} at=#{at}"
end
class N4
  def start(name) = "n4 #{name} #{yield}"
end
class Timer
  def start = "timer"
end
class Wrapper
  def initialize(notifier)
    @notifier = notifier
  end
  def start(...) = @notifier.start(...)
end
puts Wrapper.new(N1.new).start("a", 1)
puts Wrapper.new(N2.new).start("b", 2, 3)
puts Wrapper.new(N2.new).start("c", 4)
puts Wrapper.new(N3.new).start("d", at: 5)
puts Wrapper.new(N4.new).start("e") { "blk" }
puts Wrapper.new(Timer.new).start
begin
  Wrapper.new(Timer.new).start(1)
rescue ArgumentError => e
  puts e.message
end
