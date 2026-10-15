# A short sleep in a thread wakes near its deadline.
#
# The scheduler's monitor fires sleep timers. With no descriptor of its own to
# watch it waited in poll(), which counts in whole milliseconds, so a sleep of
# 0.2 ms woke at least 1 ms after it began, every time. It now wakes about
# 0.1 ms after its deadline.
#
# The fastest of 50 such sleeps is what is checked, not a typical one: a busy
# machine can only delay a thread's resumption, so it pushes slow sleeps up but
# leaves the fastest near what the monitor gives. The old poll() put even the
# fastest above 1 ms; now it is about 0.25 ms, well under the 0.6 ms asked here.
def now = Process.clock_gettime(Process::CLOCK_MONOTONIC)

took = []
t = Thread.new do
  50.times do
    t0 = now
    sleep 0.0002
    took << now - t0
  end
end
t.join
puts "50 sleeps of 0.2 ms"
puts "none woke early: #{took.min >= 0.0002}"
puts "the fastest woke within 0.6 ms: #{took.min < 0.0006}"
