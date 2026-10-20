# Socket#bind and Socket#connect take one argument in CRuby, the address
# packed (Socket.sockaddr_in, Addrinfo#to_sockaddr). A Socket made with
# Socket.new was refused at compile time for both, so it could be bound or
# connected only through connect_nonblock.
require "socket"

# a listener made by hand, and a TCPSocket that reaches it
srv = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
p srv.bind(Socket.sockaddr_in(0, "127.0.0.1"))
p srv.listen(5)
port = Socket.unpack_sockaddr_in(srv.getsockname)[0]
p srv.local_address.ip_address
visitor = TCPSocket.new("127.0.0.1", port)
p visitor.remote_address.ip_port == port

# a client made by hand, connecting to a TCPServer from a thread
server = TCPServer.new("127.0.0.1", 0)
cl = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
t = Thread.new { cl.connect(Socket.sockaddr_in(server.addr[1], "127.0.0.1")) }
conn = server.accept
p t.value
cl.write("Seongsu Bridge")
cl.close
p conn.read

# datagrams, bound through Addrinfo#to_sockaddr and connected through
# Socket.pack_sockaddr_in
rx = Socket.new(Socket::AF_INET, Socket::SOCK_DGRAM, 0)
p rx.bind(Addrinfo.udp("127.0.0.1", 0).to_sockaddr)
rport = rx.local_address.ip_port
tx = Socket.new(Socket::AF_INET, Socket::SOCK_DGRAM, 0)
p tx.connect(Socket.pack_sockaddr_in(rport, "127.0.0.1"))
tx.write("Jayang-dong")
p rx.recv(32)
p Socket.unpack_sockaddr_in(tx.getpeername) == [rport, "127.0.0.1"]

# a port another socket holds, and one nothing listens on any more
taken = Socket.new(Socket::AF_INET, Socket::SOCK_DGRAM, 0)
begin
  taken.bind(Socket.sockaddr_in(rport, "127.0.0.1"))
rescue Errno::EADDRINUSE => e
  p e.class
end
visitor.close
srv.close
late = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
begin
  late.connect(Socket.sockaddr_in(port, "127.0.0.1"))
rescue Errno::ECONNREFUSED => e
  p e.class
end

# a UDPSocket's bind takes a host and a port, and a TCPSocket has none
begin
  UDPSocket.new.bind(Socket.sockaddr_in(0, "127.0.0.1"))
rescue ArgumentError => e
  puts e.message
end
begin
  conn.bind(Socket.sockaddr_in(0, "127.0.0.1"))
rescue NoMethodError => e
  puts e.message
end
[conn, server, rx, tx, taken, late].each(&:close)
