# A negative timeout to ConditionVariable#wait raises ArgumentError before
# the mutex is let go, as CRuby's does; the mutex is still held in the rescue.
m = Thread::Mutex.new
cv = Thread::ConditionVariable.new

def try(m, cv, timeout)
  m.synchronize do
    begin
      cv.wait(m, timeout)
      :no_raise
    rescue ArgumentError => e
      [e.class, e.message, m.owned?]
    end
  end
end

p try(m, cv, -1)
p try(m, cv, -0.5)
p try(m, cv, [-2, "x"][0])
p m.locked?

# with threads running, too
t = Thread.new { try(m, cv, -3) }
p t.value
p try(m, cv, 0)
