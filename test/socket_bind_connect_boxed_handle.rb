# A socket a block or a thread takes as its parameter, or one read out of an
# Array, is a boxed handle. #bind, #connect, #listen, #recv_nonblock,
# #local_address, #remote_address, #getsockname and #getpeername on one
# raised NoMethodError naming the socket's class; they answer as on a typed
# socket.
require "socket"

socks = [UDPSocket.new, UDPSocket.new]
p socks.map { |s| s.bind("127.0.0.1", 0) }
p socks.map { |s| s.local_address.ip_address }
p socks.map { |s| Socket.unpack_sockaddr_in(s.getsockname)[1] }
ports = socks.map { |s| s.local_address.ip_port }
p ports == socks.map { |s| s.addr[1] }

# each one connected to the other, one through a thread's parameter
t = Thread.new(socks[0]) { |s| s.connect("127.0.0.1", ports[1]) }
p t.value
p socks[1].connect("127.0.0.1", ports[0])
p socks.map { |s| s.remote_address.ip_port } == ports.reverse
p socks.map { |s| Socket.unpack_sockaddr_in(s.getpeername)[0] } == ports.reverse

# nothing waiting, then a datagram on each
p socks.map { |s| s.recv_nonblock(32, exception: false) }
begin
  socks.each { |s| s.recv_nonblock(32) }
rescue IO::WaitReadable => e
  p e.is_a?(IO::WaitReadable)
end
socks[1].write("Seongsu Bridge")
socks[0].write("Jayang-dong")
socks.each { |s| s.wait_readable }
p socks.map { |s| s.recv_nonblock(32) }
socks[1].write("Children's Grand Park")
socks[0].wait_readable
p socks.map { |s| s.recv_nonblock(32, exception: false) }

servers = [TCPServer.new("127.0.0.1", 0)]
p servers.map { |s| s.listen(16) }
port = servers[0].addr[1]
conns = [TCPSocket.new("127.0.0.1", port)]
peer = servers[0].accept
p conns.map { |c| c.remote_address.ip_address }
p conns.map { |c| c.remote_address.ip_port == port }
p conns.map { |c| Socket.unpack_sockaddr_in(c.getpeername) == [port, "127.0.0.1"] }
p Thread.new(peer) { |c| c.getsockname }.value == conns[0].getpeername
p Thread.new(peer) { |c| c.local_address.ip_port }.value == port

# a class of the program's own that answers #connect, beside a socket
class Ferry
  def connect(host, port) = "ferry to #{host}"
end
p [Ferry.new, socks[0]].map { |x| x.connect("127.0.0.1", ports[1]) }

begin
  [1, servers[0]].each { |x| x.listen(1) }
rescue NoMethodError => e
  puts e.message.tr("`", "'")
end
socks.each(&:close)
conns.each(&:close)
peer.close
servers.each(&:close)
