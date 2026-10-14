# A finished thread's stack goes back to a cache and the next thread or fiber
# of the same size takes it, guard page still in place. The cache is kept
# small here so stacks are also unmapped when it is full, and every answer
# is exact. test/fiber_stack_cache_guard.rb runs a reused stack off its end.
ENV["SPINEL_FIBER_STACK_CACHE"] = "4"

def depth(n) = n == 0 ? 0 : 1 + depth(n - 1)

# rounds of short-lived threads, each recursing a little into its stack
total = 0
60.times do |r|
  ts = Array.new(8) { |w| Thread.new(r, w) { |rr, ww| depth(100 + (rr * 8 + ww) % 50) } }
  total += ts.sum(&:value)
end
p total

# plain fibers: their stacks return through the collector
sum = 0
300.times do |i|
  f = Fiber.new { |x| Fiber.yield(x + 1); x + 2 }
  sum += f.resume(i) + f.resume
end
p sum
