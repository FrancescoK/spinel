# A short sleep in a thread wakes near its deadline, and never before it.
#
# The scheduler's monitor fires sleep timers. With no descriptor of its own to
# watch it waited in poll(), which counts in whole milliseconds, so a sleep of
# 0.2 ms woke about 1.15 ms after it began. It now wakes about 0.1 ms after
# its deadline (#9234).
#
# Only that no sleep wakes early is checked here. How soon after its deadline
# a sleep wakes depends on the machine: a shared CI runner (macOS, twice) held
# up nearly all 200 past any bound the test could name, so the wake latency
# is a measurement, not a corpus answer.
def now = Process.clock_gettime(Process::CLOCK_MONOTONIC)

took = []
t = Thread.new do
  200.times do
    t0 = now
    sleep 0.0002
    took << now - t0
  end
end
t.join
puts "200 sleeps of 0.2 ms"
puts "none woke early: #{took.min >= 0.0002}"
