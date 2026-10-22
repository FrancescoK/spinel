# Socket.unix(path) and Socket.tcp(host, port) connect as UNIXSocket.new and
# TCPSocket.new do, and answer a Socket (#9934).
require 'socket'
path = "/tmp/spinel-sock-unix-#{Process.pid}.sock"
server = UNIXServer.new(path)
client = Socket.unix(path)
client.write("hi")
conn = server.accept
p conn.readpartial(2)
p client.class, client.is_a?(BasicSocket)
client.close; conn.close; server.close
File.delete(path)

srv = TCPServer.new("127.0.0.1", 0)
port = srv.addr[1]
c2 = Socket.tcp("127.0.0.1", port)
s2 = srv.accept
c2.write("yo")
p s2.readpartial(2)
p c2.class
c2.close; s2.close; srv.close
