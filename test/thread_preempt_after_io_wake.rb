# A CPU-bound thread is still timesliced right after a burst of I/O parks and
# wakes. Those leave the monitor in short timed waits, and a green thread's run
# then skips the wake it used to send the monitor (it comes back within a
# quantum on its own and starts ticking): the spinner below must still be
# preempted, or the sleeper -- on the same, only worker -- never runs and the
# spinner runs out its whole budget. And again once the monitor has gone back
# to long waits, with a reader parked on a deadline.
ENV["SPINEL_WORKERS"] = "1"

r, w = IO.pipe
r2, w2 = IO.pipe
echo = Thread.new do
  200.times do
    r.wait_readable(5.0)
    w2.write(r.readpartial(16))
  end
end
200.times do
  w.write("x")
  r2.wait_readable(5.0)
  r2.readpartial(16)
end
echo.join

def starves?
  flag = false
  sleeper = Thread.new { sleep 0.01; flag = true }
  spinner = Thread.new do
    t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    n = 0
    until flag
      n += 1
      break if Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0 > 5.0
    end
    flag
  end
  sleeper.join
  !spinner.value
end

# Right after the burst: the monitor waits a quantum at most, and the
# spinner's run does not signal it.
a = starves?

# Long after it, with a reader parked on a 30 s deadline, the monitor is back
# in its 50 ms waits, and no timer is set to bring it sooner: the spinner's
# run is what tells it to look. The thread that ends the spin is made after
# the spinner, so it runs only once the spinner is preempted.
idle_r, idle_w = IO.pipe
reader = Thread.new { idle_r.wait_readable(30.0) }
sleep 0.3
done = false
spinner = Thread.new do
  t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  until done
    break if Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0 > 5.0
  end
  done
end
Thread.new { done = true }.join
b = !spinner.value
idle_w.write("x")
reader.join

puts a || b ? "starved" : "preempted"
