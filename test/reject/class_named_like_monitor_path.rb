# Monitor does not live under Thread, so CRuby makes a new class
# Thread::Monitor. Spinel cannot keep it apart from Monitor, so it refuses.
class Thread::Monitor
  def hi = "mine"
end

puts Thread::Monitor.new.hi
p Monitor.new.respond_to?(:hi)
