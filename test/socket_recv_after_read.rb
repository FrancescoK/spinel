# recv on a stream socket serves what a read already pulled into the IO's
# buffer first: it read the descriptor directly and answered "" while
# "BCDEF" sat in the buffer. At EOF it answers nil.
require "socket"

server = TCPServer.new("127.0.0.1", 0)
wrote = Queue.new
done = Queue.new
writer = Thread.new do
  peer = server.accept
  peer.write("ABCDEF")
  wrote << 1
  done.pop
  peer.close
end

client = TCPSocket.new("127.0.0.1", server.addr[1])
wrote.pop
p [:read, client.read(1)]
p [:recv, client.recv(1024)]
done << 1
writer.join
p [:recv_at_eof, client.recv(1024)]
client.close
server.close
