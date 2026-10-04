path = "/tmp/sp_outbuf_ignored_#{Process.pid}.txt"
File.write(path, "hello world")
File.open(path) { |f| b = +""; r = f.sysread(3, b); p r; p b; p r.equal?(b) }
File.open(path) { |f| b = +""; r = f.readpartial(3, b); p r; p b; p r.equal?(b) }
File.delete(path)
