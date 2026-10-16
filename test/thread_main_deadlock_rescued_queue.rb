# Main deadlocks popping a Queue nothing will push to, rescues the error, and
# uses the Queue again. It is no longer waiting on it: it raised while still
# on the Queue's wait list, counted as a waiter and blocked, so the next push
# went to that stale entry.
q = Queue.new
begin
  q.pop
rescue Exception
  puts "pop with nothing to push: deadlock"
end
p q.num_waiting
p Thread.current.status
t = Thread.new { q.push 1 }
p q.pop
t.join
p q.num_waiting
