# A blocking SSLSocket#connect waits for its peer the way a socket read does:
# the thread parks on the descriptor and its OS worker goes back to the
# others. A wait inside SSL_connect kept the worker in the kernel instead,
# and the next collection any other thread needed waited with it, for as
# long as the peer stayed quiet.
#
# The peer here accepts and never answers, so the handshake cannot finish.
# The main thread meanwhile allocates enough to need collections, and has to
# reach the end of that before the peer is closed. Without the park this
# test does not finish.
require "openssl"
require "socket"

srv = TCPServer.new("127.0.0.1", 0)
cli = TCPSocket.new("127.0.0.1", srv.addr[1])
peer = srv.accept

t = Thread.new do
  ssl = OpenSSL::SSL::SSLSocket.new(cli)
  begin
    ssl.connect
    "connected"
  rescue StandardError
    "connect failed when the peer closed"
  end
end

# The ClientHello has arrived, so the thread is in connect, waiting.
IO.select([peer])
peer.readpartial(4096)

# The main thread goes on allocating the way any other thread in a program
# would: here, a departure board for the two airports that serve Seoul,
# redrawn line by line, enough lines for several collections.
board = []
300_000.times do |i|
  airport = i.even? ? "ICN" : "GMP"
  hh = ((i / 60) % 24).to_s.rjust(2, "0")
  mm = (i % 60).to_s.rjust(2, "0")
  board << "#{airport} #{hh}:#{mm}"
  board.shift if board.size > 100
end
puts board.first
puts board.last

peer.close
puts t.value
cli.close
srv.close
