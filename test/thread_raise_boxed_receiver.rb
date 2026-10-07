# Thread#raise on a thread read back out of a Hash's keys (a boxed value):
# the exception is raised in that thread, as on a typed one (webrick's
# TimeoutHandler interrupts a request thread so); a boxed Fiber still takes
# Fiber#raise, and anything else has no public raise
class TO < StandardError; end
def interrupt(thread, exception)
  thread.raise(exception) if thread.alive?
end
q = Queue.new
t = Thread.new { begin; q.pop; :done; rescue TO => e; [:rescued, e.message]; end }
info = { t => 1, "k" => 2 }
sleep 0.05
r = nil
info.each_key { |th| r = interrupt(th, TO.new("execution timeout")) unless th.is_a?(String) }
p t.value, r
t2 = Thread.new { begin; q.pop; rescue => e; [e.class, e.message]; end }
sleep 0.05
[t2, :x].each { |th| th.raise("stop") if th.is_a?(Thread) }
p t2.value
f = Fiber.new { begin; Fiber.yield; rescue TO => e; [:fiber, e.message]; end }
f.resume
xs = [f, 1]
p xs[0].raise(TO.new("boom"))
begin
  xs[1].raise("no")
rescue NoMethodError => e
  puts e.message
end
