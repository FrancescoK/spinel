# spinel: int64 -- the RangeError checks pass 2**33, which a 32-bit Integer cannot hold
require "socket"

# Socket.tcp_server_sockets answers listening Sockets; TCPServer.for_fd
# wraps one's descriptor once autoclose is off, the way WEBrick listens.
socks = Socket.tcp_server_sockets("127.0.0.1", 0)
p socks.size
p socks[0].class
servers = socks.map { |s|
  p(s.autoclose = false)
  t = TCPServer.for_fd(s.fileno)
  s.close
  t
}
srv = servers[0]
p srv.class
port = srv.addr[1]
p port > 0

c = TCPSocket.new("127.0.0.1", port)
a = srv.accept
c.write "hello\n"
p a.gets
a.close
c.close

# the bound port is taken
begin
  Socket.tcp_server_sockets("127.0.0.1", port)
rescue SystemCallError => e
  p e.class
end
srv.close

# the port-only form listens on every local address
all = Socket.tcp_server_sockets(0)
p all.size > 0
all.each { |s| s.close_on_exec = true; s.close }

# a descriptor that is not open
begin
  TCPServer.for_fd(-1)
rescue SystemCallError => e
  p e.class
end

# an Integer past a C int is a RangeError, not a different port or fd
begin
  Socket.tcp_server_sockets("127.0.0.1", 2**33) # spinel: int64
rescue RangeError => e
  p e.message
end
begin
  TCPServer.for_fd(2**33 + 1) # spinel: int64
rescue RangeError => e
  p e.message
end
begin
  TCPServer.for_fd(-2**33) # spinel: int64
rescue RangeError => e
  p e.message
end
