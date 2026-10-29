# A method whose kept block yields keeps the block it is given
# `proc { yield }` runs the method's caller's block when the Proc is called,
# here inside a loop that never names that block: the block is a kept one,
# and its `src.next` keeps the loop's StopIteration handler. Nothing else in
# the program keeps a block that can raise one.

class Hook
  def keep = @cb = proc { yield }
  def fire = @cb.call
end
src2 = [5].each
hook = Hook.new
hook.keep { src2.next }
fired = 0
loop do
  fired += 1
  hook.fire
end
p fired

