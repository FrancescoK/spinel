# A Fiber or Thread body that names the variable it's being assigned to
# sees the handle, not nil.

f = Fiber.new do
  GC.start
  p f.alive?
  begin
    f.resume
  rescue FiberError => e
    p e.class
  end
  Fiber.yield f.equal?(Fiber.current)
  :done
end
p f.resume
p f.resume

g = Fiber.new { g = nil; :cleared }
p g.resume
p g.nil?

t = Thread.new do
  sleep 0.01
  GC.start
  t.equal?(Thread.current)
end
p t.value

ts = Thread.new { ts.name = "self-named"; ts.name }
p ts.value
