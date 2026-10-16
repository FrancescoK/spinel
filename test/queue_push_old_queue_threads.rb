# Several threads push onto one Queue that has survived collections and so
# lives in the old generation, which makes each push run the write
# barrier on it. The barrier ran before the push took the scheduler lock,
# so two pushers raced on the queue's header word. Under
# scripts/tsan-run.sh with SPINEL_WORKERS=2..8 that was reported as a data
# race (sp_gc_wb against sp_gc_wb_slow); the barrier now runs under the
# lock, beside the store it covers. Plain `make test` keeps the program
# honest (the total is deterministic); the TSan gate is where the race
# shows.
q = Queue.new
GC.start
GC.start
ts = (1..4).map do |i|
  Thread.new do
    300.times { |j| q << "p#{i}-#{j}" }
  end
end
n = 0
1200.times { n += q.pop.size }
ts.each(&:join)
p n
