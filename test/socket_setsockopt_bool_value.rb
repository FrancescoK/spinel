# setsockopt takes true/false and an option's packed bytes for its value, as
# CRuby does: true raised TypeError.
require "socket"

server = TCPServer.new("127.0.0.1", 0)
s = TCPSocket.new("127.0.0.1", server.addr[1])
p s.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)
p s.getsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE).bool
s.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, false)
p s.getsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE).bool
s.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, [1].pack("l"))
p s.getsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY).bool
s.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 0)
p s.getsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY).bool
on = [true, 1].first
s.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, on)
p s.getsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE).bool
s.close
server.close
