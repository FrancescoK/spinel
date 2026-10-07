# A variable that holds a TCPSocket or an OpenSSL::SSL::SSLSocket: setsockopt,
# and readpartial / sysread with a buffer, on the plain TCPSocket reach the IO,
# as CRuby's do. SSLSocket forwards setsockopt to its socket, as CRuby's
# SocketForwarder does.
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
peer = Thread.new { c = server.accept; c.write("hello world, again"); c.close }
sock = connect(server.addr[1], false)
peer.join
p sock.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
buf = +""
p sock.readpartial(5, buf)
p buf
handle = String.new(capacity: 16)
p sock.sysread(7, handle)
handle << "!"
p handle
p sock.readpartial(16)
