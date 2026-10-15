# A thread's death wakes everything that joins it -- main, other threads and
# timed joins -- once each, however the joins race the death. The joiners
# list is drained at death under the thread's own lock, not the scheduler's.

def wait_until_asleep(threads)
  deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 5
  until threads.all? { |t| t.status == "sleep" }
    raise "the joiners did not park" if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
    sleep 0.001
  end
end

# Threads that end at once, joined by main and by three others (one of them
# with a limit): every join returns, with the thread's value.
rounds = 200
ok = 0
rounds.times do |r|
  t = Thread.new(r) { |x| x * 2 }
  js = Array.new(3) { |k| Thread.new(t, k) { |tt, kk| kk == 0 ? tt.join(5).value : tt.value } }
  v = t.value
  ok += 1 if v == r * 2 && js.map(&:value).all? { |x| x == r * 2 }
end
puts "joins racing the death: #{ok}/#{rounds}"

# More joiners than one batch of the wake.
gate = Queue.new
target = Thread.new { gate.pop; :done }
joiners = Array.new(150) { Thread.new { target.value } }
wait_until_asleep(joiners)
gate << 1
puts "150 joiners: #{joiners.map(&:value).uniq.inspect}"

# A joiner killed while it waits leaves the others on the list.
gate2 = Queue.new
target2 = Thread.new { gate2.pop; 7 }
a = Thread.new { target2.value }
b = Thread.new { target2.value }
c = Thread.new { target2.join(10); target2.value }
wait_until_asleep([a, b, c])
b.kill
b.join
gate2 << 1
puts "after a kill: #{[a.value, c.value].inspect}, the killed one #{b.status.inspect}"

# A timed join that runs out takes itself off the list.
gate3 = Queue.new
target3 = Thread.new { gate3.pop; 9 }
puts "timed out: #{target3.join(0.01).inspect}"
gate3 << 1
puts "then: #{target3.value}"

# An exception reaches every joiner.
gate4 = Queue.new
t5 = Thread.new do
  Thread.current.report_on_exception = false
  gate4.pop
  raise ArgumentError, "boom"
end
seen = Array.new(3) { Thread.new { begin; t5.join; :none; rescue ArgumentError => e; e.message; end } }
wait_until_asleep(seen)
gate4 << 1
puts "raised: #{seen.map(&:value).inspect}"

# Main joining a thread that can never finish is told so.
stuck = Thread.new { Queue.new.pop }
begin
  stuck.join
  puts "join: returned"
rescue Exception
  puts "join: deadlock reported"
end
