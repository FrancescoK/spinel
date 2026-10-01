# Fiber#blocking?, Fiber.blocking?, Fiber.blocking { } and
# Fiber.new(blocking:). The main fiber of the program or of a Thread is
# blocking; a Fiber.new one only when asked to be. There is no fiber
# scheduler, so Fiber.scheduler is nil.

p Fiber.blocking?
p Fiber.current.blocking?
p Fiber.new { [Fiber.current.blocking?, Fiber.blocking?] }.resume
p Fiber.new(blocking: true) { [Fiber.current.blocking?, Fiber.blocking?] }.resume
p Fiber.new(blocking: false) { Fiber.blocking? }.resume
p Fiber.new(blocking: nil) { Fiber.blocking? }.resume
p Fiber.new(blocking: 1) { Fiber.blocking? }.resume
p Fiber.new { }.blocking?
p Thread.new { [Fiber.blocking?, Fiber.current.blocking?] }.value

# Fiber.blocking { |fiber| }: blocking for the block, then back
p Fiber.blocking { |f| [f.equal?(Fiber.current), Fiber.blocking?] }
p Fiber.new { Fiber.blocking { [Fiber.current.blocking?, Fiber.blocking?] } }.resume
p Fiber.new { Fiber.blocking { :value } }.resume
p Fiber.new { Fiber.blocking { :r }; Fiber.current.blocking? }.resume
p Fiber.new { Fiber.blocking { Fiber.blocking { 1 }; Fiber.blocking? } }.resume
p Fiber.new(blocking: true) { Fiber.blocking { 2 }; Fiber.blocking? }.resume
p Fiber.new { Fiber.blocking { |f| f.blocking? } }.resume
p(Fiber.new do
  begin
    Fiber.blocking { raise "boom" }
  rescue => e
    p e.message
  end
  Fiber.blocking?
end.resume)

boxed = [Fiber.new { }, 1][0]
p boxed.blocking?


# the block is a closure like any other: it writes outer locals, its
# return leaves the method, and its yield reaches the method's block
y = 1
Fiber.blocking { y += 10 }
p y
def writes
  x = 1
  s = "a"
  Fiber.blocking { x = 2; s = "b" }
  [x, s]
end
p writes
def early
  Fiber.blocking { return 7 }
  8
end
p early
def yielder
  Fiber.blocking { |f| yield f }
end
p(yielder { |f| [f.class, Fiber.blocking?] })
p Fiber.blocking { |f| f = 1 if f.nil?; f }.class

p Fiber.scheduler
p Fiber.current_scheduler
