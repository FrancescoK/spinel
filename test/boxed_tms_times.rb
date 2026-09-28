# utime, stime, cutime and cstime on a Process::Tms read out of a
# container answer its Float CPU times, as on a typed one.
t = Process.times
x = [t, 0][0]
p [x.utime, x.stime, x.cutime, x.cstime].map(&:class)
p [x.utime == t.utime, x.stime == t.stime, x.cutime == t.cutime, x.cstime == t.cstime]
p x.utime + x.stime >= 0.0
p (["s", 0][0].utime rescue $!.message)
