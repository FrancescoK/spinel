# Fiber and Thread errors carry CRuby's messages.

begin
  Fiber.new
rescue ArgumentError => e
  p e.message
end

begin
  Thread.new
rescue ThreadError => e
  p e.message
end

f = Fiber.new do
  begin
    Fiber.current.resume
  rescue FiberError => e
    p e.message
  end
  :x
end
p f.resume

begin
  Fiber.current.resume
rescue FiberError => e
  p e.message
end

a = Fiber.new { Fiber.yield }
a.resume
b = Fiber.new do
  begin
    a.resume
    p :resumed
  rescue FiberError => e
    p e.message
  end
end
b.resume

