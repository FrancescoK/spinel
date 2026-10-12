# Thread#priority / #priority=: a hint CRuby keeps per thread, clamped to
# -3..3, inherited by a thread its creator starts.
p Thread.current.priority
Thread.current.priority = 10
p Thread.current.priority
Thread.current.priority = -9
p Thread.current.priority
Thread.current.priority = 2
p Thread.new { Thread.current.priority }.value
p((Thread.current.priority = 1.9))
p Thread.current.priority
t = Thread.new do
  Thread.current.name = "worker"
  Thread.current.priority = -2
  [Thread.current.name, Thread.current.priority]
end
p t.value
begin
  Thread.current.priority = nil
rescue TypeError => e
  puts e.message
end
