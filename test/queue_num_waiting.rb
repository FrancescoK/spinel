# Queue#num_waiting counts the threads parked in #pop, and on a full
# SizedQueue the ones parked in #push too.
def settle(q, n)
  200.times { break if q.num_waiting == n; sleep 0.01 }
  q.num_waiting
end

q = Queue.new
p q.num_waiting
poppers = 3.times.map { Thread.new { q.pop } }
p settle(q, 3)
q << 1
p settle(q, 2)
q << 2
q << 3
poppers.each(&:join)
p q.num_waiting

timed = Thread.new { q.pop(timeout: 5) }
p settle(q, 1)
q << 4
timed.join
p q.num_waiting

sq = SizedQueue.new(1)
sq << :full
pushers = 2.times.map { |i| Thread.new { sq.push(i) } }
p settle(sq, 2)
sq.pop
p settle(sq, 1)
sq.pop
sq.pop
pushers.each(&:join)
p sq.num_waiting

p Thread::Queue.new.num_waiting
