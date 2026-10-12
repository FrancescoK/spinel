# kill on a boxed receiver where a program class owns the name and answers an
# Integer or nil: the call is typed as any value, so a Thread reaching the
# same dispatch answers itself, as Thread#kill does, and the program's
# method keeps its Integer or nil.
class Child
  def initialize(pid) = @pid = pid
  def kill = (@pid.positive? ? @pid : nil)
end

[Child.new(1), Child.new(0)].each(&:kill)
p [Child.new(2), Child.new(0)].map(&:kill)
sleeper = Thread.new { sleep }
[Child.new(3), Child.new(0), sleeper].each { |item| p item.kill.class }
p sleeper.join.equal?(sleeper)
p sleeper.alive?
