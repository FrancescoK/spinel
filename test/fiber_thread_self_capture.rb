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

# A thread may start before `t = ` has stored its handle: it waits for the
# assignment, as a CRuby program racing its own Thread.new must.
t = Thread.new do
  Thread.pass until t
  GC.start
  t.equal?(Thread.current)
end
p t.value

ts = Thread.new { Thread.pass until ts; ts.name = "self-named"; ts.name }
p ts.value
