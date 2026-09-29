# File#flock answers 0 when it gets the lock and false when a LOCK_NB
# request finds it held. Any other failure raises.
path = "/tmp/sp_flock_nonblock_held_#{Process.pid}.lock"
File.write(path, "")
a = File.open(path)
b = File.open(path)
p a.flock(File::LOCK_EX)
p b.flock(File::LOCK_EX | File::LOCK_NB)
p b.flock(File::LOCK_SH | File::LOCK_NB)
p a.flock(File::LOCK_UN)
p b.flock(File::LOCK_SH | File::LOCK_NB)
p a.flock(File::LOCK_SH | File::LOCK_NB)
p a.flock(File::LOCK_EX | File::LOCK_NB)
puts "held" unless a.flock(File::LOCK_EX | File::LOCK_NB)

# the same through a boxed receiver
boxed = [a, 0][0]
p boxed.flock(File::LOCK_EX | File::LOCK_NB)
p b.flock(File::LOCK_UN)
p boxed.flock(File::LOCK_EX | File::LOCK_NB)

e = (b.flock(0) rescue $!)
p e.is_a?(SystemCallError)   # EBADF on macOS, EINVAL on Linux
a.close
b.close
File.delete(path)
