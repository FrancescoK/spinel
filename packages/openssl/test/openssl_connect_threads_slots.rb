# Fifteen threads start a TLS handshake at the same moment, each on its own
# connection, and every peer receives a ClientHello. Threads set their
# connections up on parallel workers, and two set up at once could be given
# one slot: the later overwrote the earlier, both SSLSockets drove the later
# one's SSL, and the earlier one's peer was sent nothing.
#
# The peers never answer, so each handshake stops after its hello, and
# connect_nonblock answers :wait_readable.
require "openssl"
require "socket"

COUNT = 16

server = TCPServer.new("127.0.0.1", 0)
port = server.addr[1]
clients = []
peers = []
COUNT.times do
  clients << TCPSocket.new("127.0.0.1", port)
  peers << server.accept
end

ctx = OpenSSL::SSL::SSLContext.new
ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
ssls = clients.map { |sock| OpenSSL::SSL::SSLSocket.new(sock, ctx) }

# The first handshake starts on the main thread, alone, so OpenSSL has set
# itself up before the threads begin: on macOS, threads that make OpenSSL's
# first calls at the same moment can hang, which is not what this tests.
p ssls[0].connect_nonblock(exception: false)

# Every thread waits on the queue, so the handshakes start together rather
# than one after another as the threads come up.
start = Queue.new
threads = ssls.drop(1).map do |ssl|
  Thread.new(ssl) do |s|
    start.pop
    s.connect_nonblock(exception: false) == :wait_readable
  end
end
(COUNT - 1).times { start << :go }
p threads.map(&:value).uniq

# A TLS record of type 22, a handshake message, on every connection.
hellos = peers.count do |peer|
  ready = IO.select([peer], nil, nil, 5)
  ready && peer.readpartial(5).getbyte(0) == 22
end
p hellos

ssls.each(&:sysclose)
clients.each(&:close)
peers.each(&:close)
server.close
