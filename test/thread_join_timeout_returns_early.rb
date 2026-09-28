# Thread#join(limit) waits AT MOST limit seconds: it answers as soon as the
# thread finishes, not when the limit runs out. The first cut slept the whole
# timeout in one go, which made `t.join(5)` on a thread finishing in 50ms a
# five-second wait -- a bounded wait turned into a fixed one.
#
# The elapsed-time assertions are deliberately loose (a whole second either
# way) so this pins the shape and not the machine.

# Self-join must fail immediately, including before any thread has started the
# scheduler's timer monitor. Exercise the timed, untimed, and value paths.
begin
  Thread.current.join(1)
  puts false
rescue ThreadError
  puts true
end

begin
  Thread.current.join
  puts false
rescue ThreadError
  puts true
end

begin
  Thread.current.value
  puts false
rescue ThreadError
  puts true
end

t0 = Time.now
quick = Thread.new { sleep 0.05 }
r = quick.join(5)
early = Time.now - t0
puts r.nil?
puts early < 1.0

# and it does wait when the thread outlives the limit
t1 = Time.now
slow = Thread.new { sleep 5 }
r2 = slow.join(0.2)
waited = Time.now - t1
puts r2.nil?
puts waited >= 0.15
puts waited < 2.0
slow.kill

# an already-dead thread answers at once
done = Thread.new { 1 }
done.join
puts done.join(5).nil?

# a limit of zero or less does not wait
z = Thread.new { sleep 5 }
puts z.join(0).nil?
puts z.join(-1).nil?
z.kill

# the thread's exception still reaches the joiner through the timed form
Thread.report_on_exception = false
bad = Thread.new { raise ArgumentError, "bad" }
begin
  bad.join(5)
  puts "no raise"
rescue ArgumentError => e
  puts e.message
end
