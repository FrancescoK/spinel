# write on an IO handle read out of a container (a File, $stdout) writes
# every argument in order and answers the total byte count, as on a typed
# File; with no arguments it writes nothing and answers 0. The receiver
# and the arguments are evaluated in order before anything is written.
path = "/tmp/sp_boxed_file_write_args_#{Process.pid}.txt"
def fresh(path)
  h = File.open(path, "a")
  h.sync = true
  [h, 0][0]
end
File.write(path, "")

f = fresh(path)
p f.write("a", "b", "c")
p f.write(1, :s, 2.5, nil, "\n")
p f.write
p f.write("x\0y", "z")
v = [1, "é"][1]
p f.write(v, [1, 2], "\n")
n = 0
p f.write("#{n += 1}", "#{n += 1}", "\n")
a = ["p", "q"]
p f.write(*a, "\n")
p f.write(*a)
none = [nil, f][0]
p none&.write("never", "written")
def show(q) = (print "show #{q}\n"; q)
q = 0
p f.write(show(q), (q += 1), "\n")
def recv(f, n) = (print "recv #{n}\n"; f)
p recv(f, n).write("x", (n += 1), "\n")
f.close
e = (f.write rescue $!)
p [e.class, e.message]

# the handle a call answers, held nowhere else, across arguments that
# allocate
p fresh(path).write("k#{("r" * 3000).clear}", "l#{("s" * 3000).clear}", "\n")
p File.read(path)

o = [$stdout, 0][0]
p o.write("out", 1, "\n")
File.delete(path)
