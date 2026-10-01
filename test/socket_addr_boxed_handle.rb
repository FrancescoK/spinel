# addr / peeraddr on a socket handle held in a boxed slot: a socket passed
# into a Thread, or read out of an Array.
require "socket"

srv = TCPServer.new("127.0.0.1", 19394)
done = Queue.new
server_side = Thread.new do
  c = srv.accept
  Thread.new(c) do |cc|
    peer = cc.peeraddr
    mine = cc.addr
    line = [peer[0], peer[3], mine[0], mine[1] == 19394]
    done.pop
    cc.close
    line
  end.value
end
s = TCPSocket.new("127.0.0.1", 19394)
boxed = [s, 1][0]
p boxed.peeraddr[1] == 19394, boxed.addr[3]
done << :ok
p server_side.value
s.close
