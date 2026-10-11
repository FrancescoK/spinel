# A socket read back out of an Array is a boxed handle; #shutdown on it
# answers 0 as on a typed one, and the peer sees the closed direction.
# (The sockets shut down are connected ones: shutdown on a listening socket
# answers 0 on Linux but raises ENOTCONN on macOS.)
require "socket"

class Server
  def initialize
    @listener = TCPServer.new("127.0.0.1", 0)
    @conns = []
  end

  def port = @listener.addr[1]

  def accept = @conns << @listener.accept

  # its own #shutdown, which stops each connection it kept
  def shutdown
    @conns.each { |s| p s.shutdown }
    :stopped
  end
end

srv = Server.new
c = TCPSocket.new("127.0.0.1", srv.port)
srv.accept
p srv.shutdown

serv = TCPServer.new("127.0.0.1", 0)
pair = [TCPSocket.new("127.0.0.1", serv.addr[1])]
conn = serv.accept
pair.each { |s| p s.shutdown(Socket::SHUT_WR) }
p conn.read

begin
  [1, serv].each { |s| s.shutdown }
rescue NoMethodError => e
  puts e.message.tr("`", "'")
end
