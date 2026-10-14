# Threads parked on I/O leave the waiter list from anywhere in it, not just
# its head, and the rest stay parked and wakeable.
#
# 40 threads each wait on a pipe of their own. Every fifth one waits in
# IO.select with a short timeout and times out while the others are still
# parked; another fifth are killed, newest first; the remaining ones are
# woken by writes in an order unrelated to the one they parked in. A thread
# that left from the middle of the list and cut off the waiters behind it
# would leave them parked for good, and the join below would never return.
#
# Then the list must be empty: a thread that waits on a Queue nobody will push
# to is a deadlock, which join reports. A waiter left behind on the list -- one
# that was unlinked but still reachable from it -- is I/O the scheduler would
# keep waiting for, and the join would hang instead.
n = 40
pipes = Array.new(n) { IO.pipe }
got = Array.new(n, "killed")
arrived = Queue.new
threads = Array.new(n) do |i|
  Thread.new(i) do |k|
    r = pipes[k][0]
    arrived << k
    if k % 5 == 4
      got[k] = IO.select([r], nil, nil, 0.05) ? "ready" : "timed out"
    else
      got[k] = "read #{r.gets.chomp}"
    end
  end
end
n.times { arrived.pop }
# Started is not parked: wait until each waiter reports "sleep", which it does
# once it is on the waiter list. A select may already have timed out.
deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 5
loop do
  parked = true
  n.times do |k|
    t = threads[k]
    parked = false unless t.status == "sleep" || (k % 5 == 4 && !t.alive?)
  end
  break if parked
  raise "the threads did not reach their I/O waits" if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
  sleep 0.001
end
(n - 1).downto(0) { |k| threads[k].kill if k % 5 == 3 }
sleep 0.2
order = (0...n).map { |k| (k * 17) % n }
order.each { |k| pipes[k][1].puts(k * 3) if k % 5 < 3 }
threads.each(&:join)
n.times { |k| puts "#{k}: #{got[k]}" }

q = Queue.new
stuck = Thread.new { q.pop }
begin
  stuck.join
  puts "join: returned"
rescue Exception
  puts "join: deadlock reported"
end
