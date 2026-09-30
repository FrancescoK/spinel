# A fiber can kill itself: its ensure blocks run, it ends, and #resume
# answers nil. The main fiber of the program or of a Thread ignores it.

f = Fiber.new do
  Fiber.current.kill
  puts "not reached"
ensure
  puts "f ensure"
end
p f.resume
p f.alive?

g = Fiber.new do
  Fiber.yield 1
  Fiber.current.kill
  :not_reached
end
p g.resume
p g.resume
p g.alive?

t = Fiber.new do
  Fiber.current.kill
ensure
  puts "t ensure"
end
p t.transfer

outer = Fiber.new do
  inner = Fiber.new { Fiber.current.kill; :not_reached }
  p inner.resume
  p inner.alive?
  :outer_done
end
p outer.resume
