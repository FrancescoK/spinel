# A socket's send(data, flags, host, port) through an instance variable, or a
# local read off one, is the datagram write. Such a receiver has no type yet
# on the first pass, and the #2922 / #7193 guards only knew a receiver typed
# by then, so the call became Object#send: refused at compile time with a
# literal payload, NoMethodError naming the payload with one in a variable.
require "socket"

# a relay that holds its socket and its peer, as a TURN relay does
class Relay
  def initialize(sock, host, port)
    @sock = sock
    @host = host
    @port = port
  end

  def deliver(data) = @sock.send(data, 0, @host, @port)

  def ping = @sock.send("Jayang Station", 0, @host, @port)

  def via_local(data)
    s = @sock
    s.send(data, 0, @host, @port)
  end
end

# a listener that answers whoever wrote to it
class Echo
  def initialize
    @sock = UDPSocket.new
    @sock.bind("127.0.0.1", 0)
  end

  def port = @sock.addr[1]

  def answer
    data, from = @sock.recvfrom(64)
    @sock.send(data.upcase, 0, from[3], from[1])
  end
end

rx = UDPSocket.new
rx.bind("127.0.0.1", 0)
relay = Relay.new(UDPSocket.new, "127.0.0.1", rx.addr[1])
exit_no = 1
p relay.deliver("Meet at Guui Station exit #{exit_no}")
p rx.recvfrom(64)[0]
p relay.ping
p rx.recvfrom(64)[0]
p relay.via_local("Kondae lamb skewers")
p rx.recvfrom(64)[0]

echo = Echo.new
answering = Thread.new { echo.answer }
client = UDPSocket.new
client.send("Achasan", 0, "127.0.0.1", echo.port)
p client.recvfrom(64)[0]
p answering.value

# Object#send of the same shape on an instance variable still names a method
class Fare
  def add(a, b) = a + b
  def sub(a, b) = a - b
end

class Gate
  def initialize
    @fare = Fare.new
  end

  def by_name(name) = @fare.send(name, 0, 5)
  def by_string = @fare.send("sub", 9, 4)
  def by_flag(name) = @fare.send(name, Socket::MSG_PEEK, 1) == Socket::MSG_PEEK + 1
end

gate = Gate.new
p gate.by_name(:add)
p gate.by_name(:sub)
p gate.by_string
p gate.by_flag(:add)
