# ConditionVariable#wait answers what CRuby's Mutex#sleep answers: nil when
# its timeout runs out, otherwise the whole seconds slept, an Integer (the
# wake below comes well inside a second, so it is 0 or 1 by the wall clock).
m = Thread::Mutex.new
cv = Thread::ConditionVariable.new

# timed out, a positive and a zero timeout, before any thread exists
p m.synchronize { cv.wait(m, 0.01) }
p m.synchronize { cv.wait(m, 0) }
p m.owned?

def woken(m, cv, timeout)
  ready = false
  t = Thread.new do
    m.synchronize do
      ready = true
      timeout ? cv.wait(m, timeout) : cv.wait(m)
    end
  end
  Thread.pass until m.synchronize { ready }
  m.synchronize { cv.signal }
  v = t.value
  [v.class, v.is_a?(Integer) && v >= 0 && v <= 1]
end

# woken by a signal: timed, untimed, and a nil timeout
p woken(m, cv, 5)
p woken(m, cv, nil)
p woken(m, cv, 5.0)

# timed out once threads exist
p Thread.new { m.synchronize { cv.wait(m, 0.02) } }.value
p m.synchronize { cv.wait(m, 0.01) }

# a nil timeout value only known at run time, and a timeout read from a
# mixed variable
def no_timeout = nil
t = Thread.new { m.synchronize { cv.wait(m, no_timeout) } }
Thread.pass until t.status == "sleep"
m.synchronize { cv.signal }
p t.value.class
to = [0.01, "x"][0]
p m.synchronize { cv.wait(m, to) }
