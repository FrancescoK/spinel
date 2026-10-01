# The main thread runs green threads from inside a Fiber it resumed: a
# Thread.pass sweep there switched each one in, and the thread switched back
# to the worker's root fiber, whose context was never saved (#resume saves it
# in the fiber's caller_ctx), so the program crashed.

# a sleeping thread, waited for with Thread.pass
f = Fiber.new do
  t = Thread.new { sleep }
  Thread.pass while t.status and t.status != "sleep"
  p t.status
  :slept
end
p f.resume

# a thread that passes back and then finishes
f = Fiber.new do
  t = Thread.new { 3.times { Thread.pass }; :ran }
  Thread.pass
  t.value
end
p f.resume

# a thread that sleeps a little, then is joined
f = Fiber.new do
  t = Thread.new { sleep 0.01; 5 }
  Thread.pass
  t.value + 1
end
p f.resume

# the fiber yields and is resumed again around the sweeps
f = Fiber.new do
  q = Queue.new
  t = Thread.new { q << 1; Thread.pass; q << 2 }
  Thread.pass
  Fiber.yield q.pop
  Thread.pass
  t.join
  q.pop
end
p f.resume
p f.resume
p :done
