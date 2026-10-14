# spinel: not-cruby -- a green thread that runs off its stack is stopped by
# Spinel's fault handler with its own message; CRuby raises SystemStackError
# in the thread instead.
#
# A stack the cache hands to a new thread keeps its guard page: when that
# thread's recursion runs off the end it faults on the guard and is reported
# as a fiber stack overflow, not a silent write into whatever lies below.
ENV["SPINEL_FIBER_STACK_CACHE"] = "4"

def depth(n) = n == 0 ? 0 : 1 + depth(n - 1)
def deep(n) = 1 + deep(n + 1)

20.times { Array.new(8) { |w| Thread.new(w) { |k| depth(50 + k) } }.each(&:join) }
puts "cache filled"
$stdout.flush   # the fatal path below does not flush the buffer
Thread.new { deep(0) }.join
puts "unreachable"
