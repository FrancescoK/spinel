# A socket a block takes as its parameter, or Thread.new hands its block,
# is a boxed handle, as an Array element is. #recv and #recvfrom on one
# raised NoMethodError, and a multiple assignment from #recvfrom was refused
# at compile time; they answer as on a typed socket.
require "socket"

socks = []
2.times { s = UDPSocket.new; s.bind("127.0.0.1", 0); socks << s }
tx = UDPSocket.new

readers = socks.map { |s| Thread.new { s.recvfrom(64)[0] } }
tx.send("ICN", 0, "127.0.0.1", socks[0].addr[1])
tx.send("GMP", 0, "127.0.0.1", socks[1].addr[1])
p readers.map(&:value)

readers = socks.map { |s| Thread.new { d, from = s.recvfrom(64); [d, from[0], from[3]] } }
tx.send("Jamsil Bridge", 0, "127.0.0.1", socks[0].addr[1])
tx.send("Cheongdam Bridge", 0, "127.0.0.1", socks[1].addr[1])
p readers.map(&:value)

t = Thread.new(socks[0]) { |sock| sock.recv(64) }
tx.send("Jayang-dong", 0, "127.0.0.1", socks[0].addr[1])
p t.value

# a class of the program's own that answers #recv, beside a socket
class Mailbox
  def initialize(msgs) = @msgs = msgs
  def recv(n) = @msgs.shift[0, n]
end
tx.send("Gimpo International Airport", 0, "127.0.0.1", socks[1].addr[1])
p [Mailbox.new(["Incheon International Airport"]), socks[1]].map { |x| x.recv(7) }

server = TCPServer.new("127.0.0.1", 0)
conns = [TCPSocket.new("127.0.0.1", server.addr[1])]
peer = server.accept
peer.write("Ttukseom Hangang Park")
p conns.map { |c| c.recv(64) }
peer.close
p conns.map { |c| c.recv(64) }

begin
  [1, socks[0]].each { |x| x.recv(4) }
rescue NoMethodError => e
  puts e.message.tr("`", "'")
end
socks.each(&:close)
tx.close
conns.each(&:close)
server.close
