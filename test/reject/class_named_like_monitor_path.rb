# Monitor does not live under Thread, so CRuby makes a new class
# Thread::Monitor. Spinel cannot keep it apart from Monitor, so it refuses.
# spinel: reject-builtin-class: unsupported class name 'Monitor': collides with the builtin class of that name
class Thread::Monitor
  def hi = "mine"
end

puts Thread::Monitor.new.hi
p Monitor.new.respond_to?(:hi)
