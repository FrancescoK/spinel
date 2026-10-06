# A recv blocked in one thread raises CRuby's IOError when another thread
# closes the socket, as readpartial does, not the kernel's EBADF (#7555).
require "socket"
server = TCPServer.new("127.0.0.1", 0)
client = TCPSocket.new("127.0.0.1", server.addr[1])
conn = server.accept

client.write("hi")
p conn.recv(10)

reader = Thread.new do
  conn.recv(10)
  puts "no error"
rescue IOError, SystemCallError => e
  puts "closed in another thread: #{e.class}: #{e.message}"
end
sleep 0.2
conn.close
reader.join

begin
  conn.recv(10)
rescue IOError => e
  puts "closed: #{e.class}: #{e.message}"
end
client.close
server.close
