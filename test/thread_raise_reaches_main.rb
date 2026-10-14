# Thread#raise aimed at the main thread from another thread was dropped:
# main runs on the scheduler's root fiber, which had no slot for it. A main
# waiting in a Queue#pop that only the raise was going to end deadlocked.
# The raise now lands in main at the wait it is in, as CRuby's does.
Thread.report_on_exception = false
def try(label)
  yield
  puts "#{label}: not raised"
rescue RuntimeError => e
  puts "#{label}: rescued #{e.message}"
end
main = Thread.current

t = Thread.new { sleep 0.05; main.raise "in sleep" }
try("sleep") { sleep 5 }
t.join

q = Queue.new
t = Thread.new { sleep 0.05; main.raise "in pop" }
try("pop") { q.pop }
t.join

hold = Queue.new
other = Thread.new { hold.pop }
t = Thread.new { sleep 0.05; main.raise "in join" }
try("join") { other.join }
t.join
hold << 1
other.join

m = Mutex.new
locked = Queue.new
release = Queue.new
holder = Thread.new { m.lock; locked << 1; release.pop; m.unlock }
locked.pop
t = Thread.new { sleep 0.05; main.raise "in lock" }
try("lock") { m.synchronize { } }
t.join
release << 1
holder.join

r, w = IO.pipe
t = Thread.new { sleep 0.05; main.raise "in read" }
try("read") { r.read(1) }
t.join
w.close
r.close
puts "done"
