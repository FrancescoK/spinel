# `Thread.attr_accessor :x` and `Fiber.attr_accessor :x` -- activesupport's
# IsolatedExecutionState gives every thread and fiber an
# active_support_execution_state -- declare an attribute on each thread and
# fiber object. A thread's is kept in that thread's own store, so threads
# never see each other's; a fiber's is kept per fiber.

Thread.attr_accessor :execution_state
Fiber.attr_accessor :execution_state
Thread.attr_reader :label
Thread.attr_writer :label

p Thread.current.execution_state
Thread.current.execution_state = { a: 1 }
p Thread.current.execution_state
Thread.current.execution_state[:b] = 2
p Thread.current.execution_state

t = Thread.new { Thread.current.execution_state = "child"; Thread.current.execution_state }
p t.value, Thread.current.execution_state

Thread.current.label = "main"
p Thread.current.label

p Fiber.current.execution_state
Fiber.current.execution_state = [1, 2]
p Fiber.current.execution_state
f = Fiber.new { Fiber.current.execution_state = :inner; Fiber.current.execution_state }
p f.resume, Fiber.current.execution_state

def state = (Thread.current.execution_state ||= {})
state[:c] = 3
p Thread.current.execution_state
