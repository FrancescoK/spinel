# A real IO in the same boxed slot as an object of a class that owns the
# method name: the class-id switch takes the object, and its builtin
# default re-enters the call for everything else. That re-entry still
# counted the owning class as a candidate, so the boxed-IO arm declined and
# the socket or pipe raised NoMethodError -- a TCPSocket beside an
# OpenSSL::SSL::SSLSocket (which defines write_nonblock and friends) in an
# HTTP server's connection list.
require "socket"

class Wrapper
  def initialize(name) = @name = name
  def write_nonblock(s, exception: true) = "#{@name} wrote #{s}"
  def read_nonblock(n, exception: true) = "#{@name} read #{n}"
  def addr = [@name]
  def peeraddr = [@name, "peer"]
end

r, w = IO.pipe
[Wrapper.new("w"), w].each { |x| p x.write_nonblock("hi\n", exception: false) }
[Wrapper.new("r"), r].each { |x| p x.read_nonblock(16, exception: false) }
[Wrapper.new("r"), r].each { |x| p x.read_nonblock(16, exception: false) }

srv = TCPServer.new("127.0.0.1", 0)
c = TCPSocket.new("127.0.0.1", srv.addr[1])
s = srv.accept
[Wrapper.new("srv"), srv].each { |x| p x.addr[0] }
[Wrapper.new("c"), c].each { |x| p x.peeraddr[0] }
c.close
s.close
srv.close
w.close
r.close
p :done
