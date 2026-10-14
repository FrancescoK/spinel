# A stack the cache hands to a new thread keeps its guard page: when that
# thread's recursion runs off the end it faults on the guard and the
# overflow is raised in the thread as SystemStackError, as CRuby raises it,
# rather than a silent write into whatever lies below.
ENV["SPINEL_FIBER_STACK_CACHE"] = "4"

def depth(n) = n == 0 ? 0 : 1 + depth(n - 1)
def deep(n) = 1 + deep(n + 1)

20.times { Array.new(8) { |w| Thread.new(w) { |k| depth(50 + k) } }.each(&:join) }
puts "cache filled"
r = Thread.new do
  deep(0)
  :unreachable
rescue SystemStackError
  :overflow_raised
end.value
p r
puts "after"
