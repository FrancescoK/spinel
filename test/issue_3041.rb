p001 = "/tmp/sp_io_stat_repro_#{Process.pid}.txt"
File.write(p001, "hello world\n")
File.open(p001) { |f| p f.stat.class }
File.open(p001) { |f| p f.stat.size }
File.open(p001) do |f|
  a001 = f.stat
  p a001.class
  p a001.size
end
File.delete(p001)
