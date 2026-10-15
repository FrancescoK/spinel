# The socket classes' open without a block is their new: it connects or
# binds and answers the socket, also from inside a Timeout block.
require "socket"
require "timeout"
require "tmpdir"

server = TCPServer.open("127.0.0.1", 0)
port = server.addr[1]
p server.class

client = TCPSocket.open("127.0.0.1", port)
peer = server.accept
p client.class
client.puts "ping"
p peer.gets
client.close
peer.close

timed = Timeout.timeout(5) { TCPSocket.open("127.0.0.1", port) }
p timed.class
server.accept.close
timed.close
server.close

any_host = TCPServer.open(0)
p any_host.addr[1] > 0
any_host.close

udp = UDPSocket.open
p udp.class
udp.close

raw = Socket.open(Socket::AF_INET, Socket::SOCK_STREAM)
p raw.class
raw.close

path = File.join(Dir.tmpdir, "spinel_socket_open_#{Process.pid}.sock")
unix_server = UNIXServer.open(path)
unix_client = UNIXSocket.open(path)
p unix_server.class, unix_client.class
unix_client.close
unix_server.close
File.delete(path)
