# A name getaddrinfo cannot resolve raises Socket::ResolutionError, CRuby's
# SocketError subclass carrying the resolver's EAI_* code as #error_code,
# from every call that resolves a host. The empty label in "a..b" is invalid
# DNS syntax, so the resolver rejects it before sending a query. Its own text
# differs between platforms, so only the prefix CRuby puts on it is shown.
require "socket"

HOST = "a..b"

def show(label)
  yield
  p [label, :no_error]
rescue SocketError => e
  p [label, e.class, e.message.split(":").first, e.error_code.is_a?(Integer),
     e.error_code != 0]
end

show(:getaddress) { IPSocket.getaddress(HOST) }
show(:tcp_socket) { TCPSocket.new(HOST, 80) }
show(:tcp_server) { TCPServer.new(HOST, 0) }
show(:getaddrinfo) { Socket.getaddrinfo(HOST, 80) }
show(:tcp_server_sockets) { Socket.tcp_server_sockets(HOST, 0) }
show(:sockaddr_in) { Socket.sockaddr_in(80, HOST) }
u = UDPSocket.new
show(:udp_bind) { u.bind(HOST, 0) }
show(:udp_connect) { u.connect(HOST, 80) }
show(:udp_send) { u.send("x", 0, HOST, 80) }
u.close

begin
  IPSocket.getaddress(HOST)
rescue Socket::ResolutionError => e
  p [e.is_a?(SocketError), e.is_a?(StandardError), e.class.superclass]
end

# Other socket failures stay what they were.
begin
  TCPSocket.new("127.0.0.1", 1)
rescue SocketError
  p :socket_error
rescue SystemCallError => e
  p e.class.ancestors.include?(SystemCallError)
end

# Read through a value of more than one type, and on one made by hand.
errs = [1, "s"]
begin
  IPSocket.getaddress(HOST)
rescue => e
  errs << e
end
x = errs[2]
p x.error_code.is_a?(Integer)
p x.respond_to?(:error_code)
begin
  raise Socket::ResolutionError, "by hand"
rescue SocketError => e
  p [e.class, e.message, e.error_code]
end
