class C
  def initialize
    @cv = ConditionVariable.new
    @m  = Mutex.new
  end
  def go
    owned = nil
    @m.synchronize do
      @cv.wait(@m, 0)
      owned = @m.owned?
    end
    owned
  end
end
c = C.new
owned = nil
t = Thread.new { owned = c.go }
t.join
p owned

# A positive timeout expires on a spawned thread, exercising the scheduler's
# timer queue (the main thread's no-scheduler sleep path is different).
m = Mutex.new
cv = ConditionVariable.new
timeout = 0.05
t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
owned = nil
t = Thread.new do
  m.synchronize do
    cv.wait(m, timeout)
    owned = m.owned?
  end
end
t.join
elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0
p [elapsed >= timeout, owned]

# Coordinate through the same mutex so the signal can only happen after the
# waiter has atomically released it and parked on the condition variable.
def signal_waiter(timeout)
  m = Mutex.new
  cv = ConditionVariable.new
  ready_cv = ConditionVariable.new
  ready = false
  signaled = false
  owned = nil

  waiter = Thread.new do
    m.synchronize do
      ready = true
      ready_cv.signal
      cv.wait(m, timeout) until signaled
      owned = m.owned?
    end
  end

  m.synchronize do
    ready_cv.wait(m) until ready
    signaled = true
    cv.signal
  end

  completed_early = !waiter.join(1).nil?
  waiter.join unless completed_early
  [completed_early, owned]
end

# Signaling a timed waiter should wake it before its deadline.
p signal_waiter(5.0)

# A nil timeout remains an indefinite wait and is woken by signal.
p signal_waiter(nil)

# A non-literal expression inferred as nil is still evaluated and means no
# timeout. The signal follows the same mutex handshake as the case above.
$nil_timeout_calls = 0
def nil_timeout
  $nil_timeout_calls += 1
  nil
end

m = Mutex.new
cv = ConditionVariable.new
ready_cv = ConditionVariable.new
ready = false
owned = nil
waiter = Thread.new do
  m.synchronize do
    ready = true
    ready_cv.signal
    cv.wait(m, nil_timeout)
    owned = m.owned?
  end
end
m.synchronize do
  ready_cv.wait(m) until ready
  cv.signal
end
waiter.join
p [$nil_timeout_calls, owned]

# Thread#raise interrupts a condition wait only after it has reacquired m.
def interrupt_wait_with_mutex(timed)
  m = Mutex.new
  cv = ConditionVariable.new
  ready_cv = ConditionVariable.new
  ready = false
  owned = nil
  waiter = Thread.new do
    m.synchronize do
      ready = true
      ready_cv.signal
      begin
        timed ? cv.wait(m, 10.0) : cv.wait(m)
      rescue RuntimeError
        owned = m.owned?
      end
    end
  end
  m.synchronize { ready_cv.wait(m) until ready }
  m.synchronize do
    waiter.raise("interrupt")
    sleep 0.01
  end
  waiter.join
  owned
end

p [interrupt_wait_with_mutex(false), interrupt_wait_with_mutex(true)]
