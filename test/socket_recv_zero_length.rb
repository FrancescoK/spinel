# A zero-length recv or recvfrom waits for the peer as CRuby's does: a UDP
# one takes the next datagram and discards it, answering "", and a stream
# answers nil once a byte or the end is there. A negative length raises.
# They answered "" at once, leaving the datagram for the next read.
require "socket"

rx = UDPSocket.new
rx.bind("127.0.0.1", 0)
port = rx.addr[1]
tx = UDPSocket.new
tx.send("x", 0, "127.0.0.1", port)
tx.send("y", 0, "127.0.0.1", port)
tx.send("z", 0, "127.0.0.1", port)
p rx.recv(0)
p rx.recv(8)
d, from = rx.recvfrom(0)
p [d, d.encoding, from[0]]
tx.send("w", 0, "127.0.0.1", port)
p rx.recv(8)
begin
  rx.recvfrom(-2)
rescue ArgumentError => e
  p e.message
end
tx.close
rx.close

server = TCPServer.new("127.0.0.1", 0)
client = TCPSocket.new("127.0.0.1", server.addr[1])
peer = server.accept
client.write("ab")
p peer.recv(0)
p peer.recv(10)
begin
  peer.recv(-1)
rescue ArgumentError => e
  p e.message
end
client.close
p peer.recv(0)
p peer.recv(5)
peer.close
server.close
