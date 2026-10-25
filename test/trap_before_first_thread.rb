# A trap set before the program's first thread runs on the main thread,
# in a sleep and an IO wait, and moves to its own thread once one starts
# (#10210: the trap no longer starts the scheduler)
require "socket"
M = Mutex.new
got = []
Signal.trap("USR2") { got << :usr2 }

pid = Process.spawn("sh", "-c", "sleep 0.1; kill -USR2 #{Process.pid}")
sleep 1
Process.wait(pid)
p got

srv = TCPServer.new("127.0.0.1", 0)
c = TCPSocket.new("127.0.0.1", srv.addr[1])
s = srv.accept
pid = Process.spawn("sh", "-c", "sleep 0.1; kill -USR2 #{Process.pid}")
p IO.select([s], nil, nil, 1)
Process.wait(pid)
p got

Process.kill("USR2", Process.pid)
p got.size
M.synchronize { p Thread.new { 6 * 7 }.value }

pid = Process.spawn("sh", "-c", "sleep 0.1; kill -USR2 #{Process.pid}")
sleep 1
Process.wait(pid)
p got.size
c.close; s.close; srv.close
