# A thread's state is written under the scheduler lock but read without
# it: a contended Mutex spins only while its owner is running, and
# #alive? and #status answer from it. Here owners sometimes yield while
# they hold the mutex and the main thread polls #alive? and #status while
# the others run. Under scripts/tsan-run.sh with SPINEL_WORKERS=2..8 the
# plain stores were reported as data races against those reads
# (sp_mutex_spin_acquire against sp_sched_block and runq_push); they are
# atomic now. A thread that dies of an exception publishes DEAD only after
# the exception, so #status polled while it dies answers nil, never false.
# Plain `make test` keeps the program honest; the TSan gate is where the
# race shows.
m = Mutex.new
count = 0
ts = (1..4).map do
  Thread.new do
    300.times do
      m.synchronize do
        count += 1
        Thread.pass if count % 7 == 0
      end
    end
  end
end
polls = 0
while ts.any?(&:alive?)
  ts.each { |t| polls += 1 if t.status }
  Thread.pass
end
ts.each(&:join)
p count
p ts.map(&:alive?)
p ts.map(&:status)
p polls >= 0
Thread.report_on_exception = false
dying = (1..4).map { |i| Thread.new { 50.times { Thread.pass }; raise "t#{i}" } }
seen = []
until dying.all? { |t| !t.alive? }
  dying.each { |t| st = t.status; seen << st if st == false }
  Thread.pass
end
p dying.map(&:status)
p seen
