# Socket.getaddrinfo restricts its answer to the family and socktype it is
# given, as an Integer or by name; it answered every socktype.
require "socket"

def socktypes(rows) = rows.map { |r| r[5] }.uniq

dgram = Socket.getaddrinfo("127.0.0.1", 8484, nil, Socket::SOCK_DGRAM)
p socktypes(dgram) == [Socket::SOCK_DGRAM]
p dgram.first.values_at(0, 1, 3)
p socktypes(Socket.getaddrinfo("127.0.0.1", 8484, Socket::AF_INET, :STREAM)) == [Socket::SOCK_STREAM]
p socktypes(Socket.getaddrinfo("127.0.0.1", 8484, "AF_INET", "SOCK_DGRAM")) == [Socket::SOCK_DGRAM]
p socktypes(Socket.getaddrinfo("127.0.0.1", 8484, :INET, :DGRAM)) == [Socket::SOCK_DGRAM]
begin
  p Socket.getaddrinfo("127.0.0.1", 8484, :INET, :NO_SUCH_TYPE)
rescue SocketError => e
  p e.class
end
