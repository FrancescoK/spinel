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

# Killing a Thread's main fiber ends the thread (after its ensure), whether
# the thread's fiber kills itself or a fiber it resumed does it.
th = Thread.new do
  Fiber.current.kill
  puts "not reached"
ensure
  puts "thread ensure"
end
p th.value

th2 = Thread.new do
  main = Fiber.current
  a = Fiber.new do
    Fiber.new { main.kill; puts "not reached" }.resume
    puts "not reached"
  ensure
    puts "a ensure"
  end
  begin
    a.resume
    puts "not reached"
  rescue Exception
    puts "not rescued"
  end
end
p th2.value
puts "main goes on"

# Another thread's fibers can't be killed: the main fiber of the program or
# of a Thread, or one it made. (CRuby still ends the program at the main
# fiber's next switch after the refused kill, so that case comes last.)
other = Fiber.new { Fiber.yield; :done }
other.resume
p(Thread.new do
  other.kill
  :killed
rescue FiberError => e
  e.message
end.value)
p other.alive?

t_main = nil
t3 = Thread.new { t_main = Fiber.current; sleep 0.2; :t3_done }
sleep 0.05
begin
  t_main.kill
rescue FiberError => e
  p e.message
end
p t3.value

main_fiber = Fiber.current
p(Thread.new do
  main_fiber.kill
  :killed
rescue FiberError => e
  e.message
end.value)

# Killing the program's main fiber ends the program with status 1, after
# its ensure blocks and at_exit hooks.
at_exit { puts "at_exit" }
begin
  Fiber.new { $main.kill }.tap { $main = Fiber.current }.resume
  puts "not reached"
ensure
  puts "main ensure"
end
puts "not reached"
