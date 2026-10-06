# Resuming the root fiber from inside a Fiber switched to a context that was
# never made (the root has no stack of its own) and crashed. CRuby refuses it:
# the root is resuming the fiber that asks, or transferring when that fiber
# was entered by #transfer.

def try
  yield
rescue FiberError => e
  e.message
end

root = Fiber.current
p try { root.resume }
p Fiber.new { try { root.resume } }.resume
p Fiber.new { Fiber.new { try { root.resume } }.resume }.resume
p Fiber.new { try { root.resume } }.transfer

# a fiber in the middle of the chain is resumed, one further up is resuming
mid = nil
mid = Fiber.new { Fiber.new { try { mid.resume } }.resume }
p mid.resume
top = nil
top = Fiber.new { Fiber.new { Fiber.new { try { top.resume } }.resume }.resume }
p top.resume

# a transferred fiber that resumed the asking fiber is resuming it, and one
# that resumes itself is the current fiber
tr = nil
tr = Fiber.new { Fiber.new { try { tr.resume } }.resume }
p tr.transfer
p Fiber.new { try { Fiber.current.resume } }.transfer

# the refusal is raised in the asking fiber, which carries on
f = Fiber.new do
  r = try { root.resume }
  Fiber.yield r
  :second
end
p f.resume
p f.resume
p f.alive?
p :done
