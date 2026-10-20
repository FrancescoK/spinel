# SPINEL_WAKE_PREEMPT=1: a woken thread goes to the front of its worker's
# queue, behind the threads woken before it, and the thread running there
# yields to it at its next safepoint. RUBY_THREAD_TIMESLICE=1 gives the
# CPU-bound threads a 1 ms timeslice. Sleepers and a Queue ping-pong run
# beside more CPU-bound threads than workers, which spin until they are
# done, so most wakes land on a busy worker. (The spinners pass now and then
# for CRuby, whose woken threads otherwise wait for its 100 ms timeslice.) All three are read when the first thread starts; CRuby reads the
# timeslice at startup and the others not at all, and the output does not
# depend on them.
ENV["SPINEL_WORKERS"] = "4"
ENV["RUBY_THREAD_TIMESLICE"] = "1"
ENV["SPINEL_WAKE_PREEMPT"] = "1"

def spin(n)
  s = 0
  i = 0
  while i < n
    s += i % 7
    i += 1
  end
  s
end

$stop = false
busy = Array.new(12) do |k|
  Thread.new do
    # At least one round even when the others finish before this thread
    # first runs, as a slow machine may schedule it
    rounds = 0
    loop do
      spin(1000 + k)
      rounds += 1
      break if $stop
      Thread.pass if rounds % 16 == 0
    end
    rounds > 0
  end
end
sleepers = Array.new(6) do |k|
  Thread.new do
    n = 0
    10.times { sleep 0.0005; n += 1 }
    n + k
  end
end
ping = Queue.new
pong = Queue.new
a = Thread.new { 50.times { |i| ping << i; pong.pop }; :done }
b = Thread.new do
  s = 0
  50.times { v = ping.pop; s += v; pong << v }
  s
end

p sleepers.map(&:value)
p a.value
p b.value
$stop = true
p busy.map(&:value).uniq
