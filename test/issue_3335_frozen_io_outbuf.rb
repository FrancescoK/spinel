path = "/tmp/sp_frozen_outbuf_#{Process.pid}.txt"
File.write(path, "hello world")
File.open(path) { |f| b = ""; r = (f.read(3, b) rescue $!.class); p r }
File.open(path) { |f| b = ""; r = (f.pread(5, 0, b) rescue $!.class); p r }
File.delete(path)
