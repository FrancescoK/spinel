# A short sleep in a thread wakes near its deadline.
#
# The scheduler's monitor fires sleep timers. With no descriptor of its own to
# watch it waited in poll(), which counts in whole milliseconds, so a sleep of
# 0.2 ms woke after at least 1 ms, every time. The median of 50 such sleeps is
# now well under 1 ms (about 0.3 ms); CRuby's is about the same.
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
median = took.sort[took.size / 2]
puts "50 sleeps of 0.2 ms"
puts "none woke early: #{took.min >= 0.0002}"
puts "median under 1 ms: #{median < 0.001}"
