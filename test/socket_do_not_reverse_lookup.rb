# BasicSocket#do_not_reverse_lookup and its class-level default. A socket
# takes the class setting when it is made (true unless changed), the
# setters answer their argument, and a socket whose flag is false reports
# its host name in addr / peeraddr's third element. addr and peeraddr also
# take CRuby's per-call flag: true or :hostname looks the name up, false or
# :numeric does not, nil follows the socket's flag. WEBrick sets the flag on
# every accepted connection, which raised NoMethodError. Loopback resolves
# to "localhost".
require "socket"

p BasicSocket.do_not_reverse_lookup
srv = TCPServer.new("127.0.0.1", 0)
port = srv.addr[1]
c = TCPSocket.new("127.0.0.1", port)
s = srv.accept
p [s.do_not_reverse_lookup, c.do_not_reverse_lookup, srv.do_not_reverse_lookup]
p(s.do_not_reverse_lookup = false)
p(s.do_not_reverse_lookup = nil)
p s.do_not_reverse_lookup
p(s.do_not_reverse_lookup = 1)
p s.do_not_reverse_lookup
p s.peeraddr[2]

s.do_not_reverse_lookup = false
p s.peeraddr.values_at(0, 2, 3)
p s.addr[2]
p [s.addr(true)[2], s.addr(false)[2], s.addr(:hostname)[2], s.addr(:numeric)[2], s.addr(nil)[2]]
s.do_not_reverse_lookup = true
p [s.addr(true)[2], s.addr(false)[2], s.addr(:hostname)[2], s.addr(:numeric)[2], s.addr(nil)[2]]
begin
  s.addr(:foo)
rescue ArgumentError => e
  p e.message
end
begin
  s.peeraddr(1)
rescue TypeError => e
  p e.message
end

# the class setting is shared by every socket class, and new sockets take it
p(BasicSocket.do_not_reverse_lookup = false)
p [TCPSocket.do_not_reverse_lookup, Socket.do_not_reverse_lookup]
c2 = TCPSocket.new("127.0.0.1", port)
s2 = srv.accept
p [s2.do_not_reverse_lookup, c2.do_not_reverse_lookup, s.do_not_reverse_lookup]
p c2.peeraddr[2]
p(TCPServer.do_not_reverse_lookup = true)
p BasicSocket.do_not_reverse_lookup

# a socket read back out of a container is boxed
conns = [s2, c2, 1]
conns[0].do_not_reverse_lookup = true
p conns[0].do_not_reverse_lookup
p [conns[0].respond_to?(:do_not_reverse_lookup=), s.respond_to?(:do_not_reverse_lookup), $stdout.respond_to?(:do_not_reverse_lookup)]
p conns[0].peeraddr[2]
p conns[1].peeraddr[2]
p conns[1].peeraddr(:numeric)[2]
p(conns[1].do_not_reverse_lookup = true)
p conns[1].addr[2]

[c, s, c2, s2, srv].each(&:close)
p :done
