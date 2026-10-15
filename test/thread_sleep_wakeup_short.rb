# A short sleep in a thread wakes near its deadline.
#
# The scheduler's monitor fires sleep timers. With no descriptor of its own to
# watch it waited in poll(), which counts in whole milliseconds, so a sleep of
# 0.2 ms woke about 1.15 ms after it began. It now wakes about 0.1 ms after
# its deadline.
#
# What is checked is how many of 200 such sleeps woke within 0.9 ms: at least
# 20. A busy machine only delays a thread's resumption, so it pushes sleeps up
# but has to hold up nearly all of them to fail this; on an idle one all 200
# are about 0.26 ms. The old poll() let at most 2 of 200 through, when the
# monitor happened to be woken for something else. The fastest of 50 under
# 0.6 ms, checked before, was too tight for a virtual CI runner, which had all
# 50 come back late in one run, and loose the other way: one early wake of the
# old monitor passed it.
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
puts "at least 20 woke within 0.9 ms: #{took.count { |x| x < 0.0009 } >= 20}"
