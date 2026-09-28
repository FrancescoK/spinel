# Many threads connect to one server at once. A connect used to block its
# worker and could be cut short by a signal, which showed up as a stray
# ECONNREFUSED. Now each connect parks until it finishes.
require "socket"
srv = TCPServer.new("localhost", 0)
port = srv.addr[1]
acceptor = Thread.new { 96.times { srv.accept.close } }
clients = (0...8).map do
  Thread.new { 12.times { TCPSocket.new("localhost", port).close }; :ok }
end
p clients.map(&:value)
acceptor.join
srv.close
