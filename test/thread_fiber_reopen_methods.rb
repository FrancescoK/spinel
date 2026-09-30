# Instance methods a `class Thread` or `class Fiber` reopening adds are the
# thread's and the fiber's, as a `class Time` reopening's are the Time's:
# reached on a typed receiver (Thread.current, a Thread.new, Fiber.current),
# with `self` inside them the thread or fiber, so a bare builtin call such
# as thread_variable_get reads that thread's own store. activesupport's
# IsolatedExecutionState gives Thread and Fiber an accessor this way.

class Thread
  def tag = "thread:#{thread_variable_get(:tag)}"
  def tag=(v)
    thread_variable_set(:tag, v)
  end
  def tagged? = thread_variable?(:tag)
end
class Fiber
  def tag = "fiber:#{alive?}"
end

p Thread.current.tagged?
Thread.current.tag = "main"
p Thread.current.tag, Thread.current.tagged?
p Fiber.current.tag
t = Thread.new { Thread.current.tag = "child"; Thread.current.tag }
p t.value, Thread.current.tag
th = Thread.current
p th.tag
