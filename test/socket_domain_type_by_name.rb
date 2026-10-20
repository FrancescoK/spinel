# Socket.new, Socket.pair and UDPSocket.new take the domain and the socket
# type as CRuby reads them: an Integer, or a Symbol or String naming the
# constant, with or without its AF_ / PF_ / SOCK_ prefix. A Symbol or a String
# raised TypeError (no implicit conversion of Symbol into Integer).
require "socket"

def kind(s) = s.getsockopt(Socket::SOL_SOCKET, Socket::SO_TYPE).int

[[:INET, :STREAM], ["INET", "DGRAM"], [:AF_INET, :SOCK_STREAM], [:PF_INET, "SOCK_DGRAM"],
 [Socket::AF_INET, :DGRAM], [:INET, Socket::SOCK_STREAM]].each do |domain, type|
  s = Socket.new(domain, type)
  p [domain, type, s.class, kind(s) == Socket::SOCK_STREAM ? :stream : :dgram]
  s.close
end

# a domain held boxed, beside an Integer one
[:INET, Socket::AF_INET].each do |domain|
  s = Socket.new(domain, :DGRAM, 0)
  p s.connect_nonblock(Socket.sockaddr_in(9, "127.0.0.1"))
  p s.local_address.ip_address
  s.close
end

# a stream Socket made by name carries a connection
server = TCPServer.new("127.0.0.1", 0)
s = Socket.new(:INET, :STREAM)
s.wait_writable if s.connect_nonblock(Socket.sockaddr_in(server.addr[1], "127.0.0.1"), exception: false) == :wait_writable
conn = server.accept
s.write("Seongsu Bridge")
s.close
p conn.read
conn.close
server.close

a, b = Socket.pair(:UNIX, :STREAM)
a.write("Jayang-dong")
a.close
p b.read
b.close
a, b = Socket.socketpair("UNIX", "DGRAM", 0)
p kind(a) == Socket::SOCK_DGRAM
a.close
b.close

u = UDPSocket.new(:INET)
u.bind("127.0.0.1", 0)
p u.local_address.ip_address
u.close

p Socket.getaddrinfo("127.0.0.1", 80, :PF_INET, :STREAM)[0].values_at(0, 3)

[[:FOO, :STREAM], [:INET, "BAR"], [nil, :STREAM]].each do |domain, type|
  begin
    Socket.new(domain, type)
  rescue SocketError, TypeError => e
    p [e.class, e.message]
  end
end
begin
  Socket.getaddrinfo("127.0.0.1", 80, :APPLE)
rescue SocketError => e
  p [e.class, e.message]
end
