# MonitorMixin: an includer's synchronize is reentrant, mon_* report the
# lock, and new_cond gives a condition variable bound to the monitor whose
# wait releases it however deeply it is held (activesupport's
# Concurrency::ShareLock waits on one in nested synchronize blocks).
require "monitor"

class Lock
  include MonitorMixin

  def initialize
    super()
    @cv = new_cond
    @n = 0
  end

  def bump
    synchronize do
      synchronize { @n += 1 }
      @cv.broadcast
      @n
    end
  end

  def wait_for(k)
    synchronize do
      mon_synchronize do
        @cv.wait_while { @n < k }
        [@n, mon_owned?]
      end
    end
  end

  def wait_until_at(k)
    synchronize do
      @cv.wait_until { @n >= k }
      @n
    end
  end

  def state = [mon_locked?, mon_owned?]
end

l = Lock.new
p l.state
t = Thread.new { l.wait_for(2) }
u = Thread.new { l.wait_until_at(3) }
sleep 0.05
l.bump
l.bump
p t.value
l.bump
p u.value
l.mon_enter
p l.state
l.mon_exit
p l.state, l.mon_try_enter
l.mon_exit

class Plain
  include MonitorMixin
  def run = synchronize { synchronize { :nested } }
end
p Plain.new.run
