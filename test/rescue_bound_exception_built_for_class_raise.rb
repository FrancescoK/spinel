# Thread#raise, Fiber#raise and Timeout.timeout(seconds, Cls) raise a class,
# not an object. The clause that rescues it with `=> e` builds the exception
# itself, so a class no `new` or `raise` of the program names still has an
# instance, and a boxed rendering of it (inside an Array, in interpolation)
# runs the class's own inspect and to_s.
require "timeout"

class FiberErr < StandardError
  def to_s = "tos-fiber"
end

class ThreadErr < StandardError
  def inspect = "custom-thread"
end

class TimeoutErr < StandardError
  def initialize(m = "dflt")
    super
    @z = 3
  end
end

fiber = Fiber.new do
  begin
    Fiber.yield
  rescue FiberErr => e
    x = [e, 1]
    p x
    puts "#{x[0]}"
  end
end
fiber.resume
fiber.raise(FiberErr)

thread = Thread.new do
  begin
    sleep 5
  rescue ThreadErr => e
    p [e, 1]
  end
end
sleep 0.1
thread.raise(ThreadErr)
thread.join

begin
  Timeout.timeout(0.05, TimeoutErr, "mm") { sleep 1 }
rescue TimeoutErr => e
  p [e, 1]
  puts e.message
end
