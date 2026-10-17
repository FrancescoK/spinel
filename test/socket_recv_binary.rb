# A socket's recv and recvfrom answer the payload as ASCII-8BIT, as CRuby's
# do. They answered UTF-8, so a datagram holding bytes above 0x7f compared
# unequal to the same bytes built with pack, and inspected as text.
require "socket"

rx = UDPSocket.new
rx.bind("127.0.0.1", 0)
port = rx.addr[1]
tx = UDPSocket.new

# a STUN-like binding request: type, length, magic cookie, transaction id,
# and a three-byte body naming Gimpo International Airport
tid = [0x8f, 0x00, 0x11, 0xa4, 0xff, 0x00, 0x7f, 0x80, 0x00, 0x01, 0x02, 0xc3].pack("C*")
req = [0x0001, 3, 0x2112a442].pack("nnN") + tid + "GMP"
tx.send(req, 0, "127.0.0.1", port)
data, from = rx.recvfrom(64)
p data.encoding
p data == req
p data.byteslice(8, 12) == tid
p data.byteslice(20, 3)
p data
p from[0]

tx.send("ICN\xFF".b, 0, "127.0.0.1", port)
got = rx.recv(64)
p got.encoding
p got == "ICN\xFF".b
p got

# a zero-length read waits for a datagram, which it discards
tx.send("x", 0, "127.0.0.1", port)
z = rx.recv(0)
p [z, z.encoding]
tx.send("y", 0, "127.0.0.1", port)
p rx.recvfrom(0)[0].encoding
tx.close
rx.close

server = TCPServer.new("127.0.0.1", 0)
client = TCPSocket.new("127.0.0.1", server.addr[1])
peer = server.accept
client.write("Ttukseom Hangang Park, Jayang-dong")
head = peer.recv(9)
p [head, head.encoding]
p peer.read(1)
rest = peer.recv(64)
p [rest, rest.encoding]
client.close
p peer.recv(64)
peer.close
server.close
