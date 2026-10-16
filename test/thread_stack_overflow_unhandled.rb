# A stack overflow in a green thread that nothing rescues ends the thread
# with SystemStackError, and #join raises it in the main thread, which
# reports it as uncaught. Spinel died on the signal inside the thread
# instead, and "before", still in stdout's buffer, was never printed.
#
# The sidecar holds Spinel's tail format for an uncaught raise, as in
# test/stack_overflow_unhandled.rb; CRuby prefixes its own frame to the
# identical text and exits 1 as well.
Thread.report_on_exception = false
puts "before"
def deep(n) = n < 0 ? 0 : 1 + deep(n + 1)
Thread.new { deep(0) }.join
puts "unreachable"
