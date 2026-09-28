# Timed waits use a direct sleep when the single-threaded runtime has no
# scheduler monitor running.
m = Mutex.new
cv = ConditionVariable.new
timeout = 0.01
t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
owned = nil
m.synchronize do
  cv.wait(m, timeout)
  owned = m.owned?
end
elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0
p [elapsed >= timeout, owned]
