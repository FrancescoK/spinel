# close_write and close_read on a closed File answer nil, as CRuby does,
# where a read-only one raised "closing non-duplex IO".
path = "/tmp/spinel_cw_closed_#{Process.pid}"
File.write(path, "abc")
f = File.open(path)
f.close
p (f.close_write rescue [$!.class, $!.message])
p (f.close_read rescue [$!.class, $!.message])
g = File.open(path)
p (g.close_write rescue [$!.class, $!.message])
g.close
File.delete(path)
# the mirror case, and a pipe end
w = File.open(path + "_w", "w")
w.close
p (w.close_read rescue [$!.class, $!.message])
File.delete(path + "_w")
r, wp = IO.pipe
r.close
p (r.close_write rescue [$!.class, $!.message])
wp.close
# a closed socket still raises, as CRuby's does
require "socket"
srv = TCPServer.new("127.0.0.1", 0)
srv.close
p (srv.close_write rescue [$!.class, $!.message])
