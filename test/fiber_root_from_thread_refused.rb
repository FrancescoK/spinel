# The main thread's root fiber, asked from another thread: it is not that
# thread's root and has no stack, so a resume made a context for it and
# crashed, and so did a transfer. CRuby refuses both.

def try
  yield
rescue FiberError => e
  e.message
end

root = Fiber.current
p Thread.new { try { root.resume } }.value
p Thread.new { Fiber.new { try { root.resume } }.resume }.value
p Thread.new { try { root.transfer } }.value
p Thread.new { Fiber.new { try { root.transfer } }.resume }.value
f = Fiber.new { 1 }
p Thread.new { try { f.resume } }.value
p f.resume
p :done
