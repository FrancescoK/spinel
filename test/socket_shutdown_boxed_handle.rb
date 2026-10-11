# A socket read back out of an Array is a boxed handle; #shutdown on it
# answers 0 as on a typed one, and the peer sees the closed direction.
require "socket"

class Server
  def initialize
    @listeners = [TCPServer.new("127.0.0.1", 0)]
  end

  def port = @listeners[0].addr[1]

  # its own #shutdown, which stops each listener it kept
  def shutdown
    @listeners.each { |s| p s.shutdown }
    :stopped
  end
end

srv = Server.new
c = TCPSocket.new("127.0.0.1", srv.port)
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
