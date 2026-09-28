# stat on a standard stream fstats its descriptor, as IO#stat does for a
# handle with no path, where it stat'ed its "<STDOUT>" placeholder.
s = $stdout.stat
p s.class
p $stdin.stat.class
p $stderr.stat.class
p [$stdout.stat.dev.is_a?(Integer), $stdin.stat.ino.is_a?(Integer)]
p File.open(__FILE__).stat.file?
# a File whose name starts with '<' is still stat'ed by its name
Dir.chdir("/tmp") do
  name = "<spinel_std_stat_#{Process.pid}"
  File.write(name, "abc")
  f = File.open(name)
  st = f.stat
  f.close
  p [st.file?, st.size]
  File.delete(name)
end
