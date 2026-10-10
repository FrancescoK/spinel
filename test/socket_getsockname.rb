# BasicSocket#getsockname / #getpeername answer the packed sockaddr of this
# end / the peer as a binary String, which Socket.unpack_sockaddr_in and
# Socket.unpack_sockaddr_un read back; an unconnected socket's getpeername
# raises ENOTCONN, as CRuby does.
require "socket"
server = TCPServer.new("127.0.0.1", 0)
port = server.addr[1]
sa = server.getsockname
p sa.encoding == Encoding::BINARY
p Socket.unpack_sockaddr_in(sa) == [port, "127.0.0.1"]
begin
  server.getpeername
rescue SystemCallError => e
  p e.class
  p e.message.end_with?(" - getpeername(2)")
end
client = TCPSocket.new("127.0.0.1", port)
conn = server.accept
p Socket.unpack_sockaddr_in(client.getpeername) == [port, "127.0.0.1"]
p client.getsockname == conn.getpeername
p conn.getsockname == client.getpeername
u = UDPSocket.new
u.bind("127.0.0.1", 0)
p Socket.unpack_sockaddr_in(u.getsockname)[0] == u.addr[1]
path = "spinel_getsockname_test.sock"
File.delete(path) if File.exist?(path)
us = UNIXServer.new(path)
uc = UNIXSocket.new(path)
p Socket.unpack_sockaddr_un(us.getsockname) == path
p Socket.unpack_sockaddr_un(uc.getpeername) == path
[client, conn, server, u, uc, us].each(&:close)
File.delete(path)
begin
  File.open(__FILE__).getsockname
rescue NoMethodError => e
  p e.class
end
begin; Socket.unpack_sockaddr_un(Socket.sockaddr_in(80,"127.0.0.1")); rescue ArgumentError => e; p e.message; end
