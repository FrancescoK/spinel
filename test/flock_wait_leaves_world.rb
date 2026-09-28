# A flock that waits for a lock leaves the world while it waits.
#
# The main thread takes an exclusive lock; a second thread asks for the same
# lock on its own descriptor and waits in flock(2). The main thread then
# collects before it unlocks. When the waiting flock holds its worker in the
# world, the collection waits for that worker, the worker waits for the lock,
# and the lock waits for the main thread the collection has stopped: the run
# hangs.
path = "/tmp/sp_flock_wait_#{Process.pid}.lock"
File.write(path, "")
a = File.open(path, "r")
p a.flock(File::LOCK_EX)
arrived = Queue.new
t = Thread.new do
  b = File.open(path, "r")
  arrived << 1
  r = b.flock(File::LOCK_EX)
  b.close
  r
end
arrived.pop
sleep 0.2
x = []
20_000.times { |i| x << "s#{i}" * 3 }
GC.start
puts "collected with #{x.size} strings"
a.flock(File::LOCK_UN)
p t.value
a.close
File.delete(path)
