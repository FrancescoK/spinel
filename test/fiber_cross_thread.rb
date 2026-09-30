# A fiber belongs to the thread that made it: resuming or transferring to it
# from another thread raises FiberError, and it stays usable at home.

f = Fiber.new { Fiber.yield 1; 2 }
p f.resume
t = Thread.new do
  f.resume
rescue FiberError => e
  e.message
end
p t.value
p f.resume

g = Fiber.new { :never }
p(Thread.new do
  g.transfer
rescue FiberError => e
  e.message
end.value)

h = Thread.new do
  x = Fiber.new { Fiber.yield 1; 2 }
  [x.resume, x.resume]
end
p h.value

q = Queue.new
w = Thread.new do
  fi = Fiber.new { Fiber.yield :a; :b }
  q << fi
  fi.resume
end
w.join
fi = q.pop
begin
  fi.resume
rescue FiberError => e
  p e.message
end
p fi.alive?

# the creating thread has exited and been collected: a later thread (which
# may sit at the same address) still can't resume its fiber
orphan = Thread.new { Fiber.new { :ran } }.value
GC.start
taken = 0
50.times do
  r = Thread.new do
    orphan.resume
    :resumed
  rescue FiberError
    :refused
  end.value
  taken += 1 if r == :resumed
  GC.start
end
p taken
