# A variable that holds a TCPSocket or an OpenSSL::SSL::SSLSocket: readpartial
# and sysread on the plain TCPSocket reach the IO, as CRuby's do (#7315), and a
# negative length raises ArgumentError there before the stream is read.
require "socket"
require "openssl"

def connect(port, tls)
  sock = TCPSocket.new("127.0.0.1", port)
  if tls
    sock = OpenSSL::SSL::SSLSocket.new(sock, OpenSSL::SSL::SSLContext.new)
    sock.connect
  end
  sock
end

server = TCPServer.new("127.0.0.1", 0)
peer = Thread.new { c = server.accept; c.write("hello world"); c.close }
sock = connect(server.addr[1], false)
peer.join
begin
  sock.readpartial(-1)
rescue ArgumentError => e
  p [e.class, e.message]
end
p sock.readpartial(5)
p sock.sysread(16)
begin
  sock.readpartial(4)
rescue EOFError => e
  p e.class
end
