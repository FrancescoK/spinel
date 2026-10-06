# pos=, sysseek, flock, fcntl and advise on an IO handle read out of a
# container answer as on a typed File: pos= and sysseek reposition,
# flock locks, fcntl answers the descriptor's flags, advise answers nil.
path = "/tmp/sp_boxed_file_controls_#{Process.pid}.txt"
File.write(path, "abcdef")
def fresh(path) = [File.open(path, "r+"), 0][0]
def seek1(f) = f.sysseek(1)

f = fresh(path)
p(f.pos = 2)
p f.read(1)
x = (f.pos = 4)
p [x, f.read]
p f.sysseek(1)
p f.sysseek(2, IO::SEEK_CUR)
p [seek1(f), f.read(2)]
v = [2, "a"][0]
p(f.pos = v)
p f.read(1)
p f.flock(File::LOCK_EX)
puts "unlocked" if f.flock(File::LOCK_UN) == 0
p f.flock(File::LOCK_SH)
p [f.fcntl(1), f.fcntl(1, 0)]
p [f.advise(:normal), f.advise(:sequential, 0, 4)]
e = (f.sysseek("1") rescue $!)
p e.class
f.close

# a File::Stat and a receiver that is no IO raise NoMethodError, the
# latter after its argument is evaluated
st = [File.stat(path), 0][0]
e = (st.sysseek(0) rescue $!)
p e.class
x = [5, "s"][0]
e = (x.flock((puts "argument"; File::LOCK_EX)) rescue $!)
p e.class
# flock is File's alone
r, w = IO.pipe
rp = [r, 0][0]
e = (rp.flock(File::LOCK_SH) rescue $!)
p [e.class, e.message]
r.close
w.close

# handles a call answers, held nowhere else, across an argument that
# allocates
n = 0
i = 0
while i < 100
  n += fresh(path).sysseek((("r" * 3000).clear; 1))
  i += 1
end
p n
File.delete(path)
