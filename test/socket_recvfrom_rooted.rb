# spinel: gc-stress
# UDPSocket#recvfrom answers [payload, [family, port, host, host]]. The
# runtime held the payload, a new String, unrooted while it copied the
# peer's address, and the call held both Strings unrooted while it made the
# two Arrays: under SPINEL_GC_STRESS=2 they were freed before the Arrays
# took them. A zero-length recvfrom made the address's String, then the
# payload's, with the address unrooted.
require "socket"
u = UDPSocket.new
u.bind("127.0.0.1", 0)
port = u.addr[1]
s = UDPSocket.new
3.times do |i|
  s.send("ping#{i}", 0, "127.0.0.1", port)
  msg, from = u.recvfrom(16)
  p [msg, from[0], from[2], from[3]]
end
s.send("tail", 0, "127.0.0.1", port)
msg, = u.recvfrom(0)
p msg
s.close
u.close
