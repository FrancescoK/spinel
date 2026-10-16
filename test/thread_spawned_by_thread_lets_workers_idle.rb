# A thread that spawns threads leaves the workers free to wait once all of
# them are done. A thread spawned by another thread goes onto that thread's
# worker's own queue, unstarted; when the same worker took it from there, the
# count of unstarted threads waiting on workers' queues stayed up, and every
# idle worker kept looking for one to steal instead of waiting: the process
# burned more than a core while it only slept.
ENV["SPINEL_WORKERS"] = "4"

20.times do
  t = Thread.new do
    kids = (0...3).map { |i| Thread.new(i) { |k| k * 2 } }
    kids.map(&:value).sum
  end
  t.join
end
puts "spawned threads from threads"

cpu0 = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
sleep 0.5
cpu = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID) - cpu0
# waiting, the process uses next to nothing; spinning workers use the whole
# half second, or more
puts(cpu < 0.2 ? "the workers waited" : "the workers spun: #{(cpu * 1000).round} ms of CPU in 500 ms")
