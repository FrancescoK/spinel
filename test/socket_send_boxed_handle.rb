# A socket's #send is BasicSocket#send, which overrides Object#send. On a
# socket a block or a thread takes as its parameter, or one read out of an
# Array (a boxed handle), `s.send(data, 0, host, port)` was Object#send and
# raised NoMethodError naming the payload. It is the socket's write there
# too, and a value of another class still takes Object#send.
require "socket"

rx = UDPSocket.new
rx.bind("127.0.0.1", 0)
port = rx.addr[1]

socks = [UDPSocket.new, UDPSocket.new]
p socks.map { |s| s.send("Seongsu Bridge", 0, "127.0.0.1", port) }
p [rx.recv(32), rx.recv(32)]
msg = "Jayang" + "-dong"
socks.each { |s| s.send(msg, 0, "127.0.0.1", port) }
p [rx.recv(32), rx.recv(32)]

# a connected socket's two-argument form, through a thread's parameter
tx = UDPSocket.new
tx.connect("127.0.0.1", port)
p Thread.new(tx) { |s| s.send("Kondae", 0) }.value
p rx.recv(32)

# a class of the program's own beside a socket takes Object#send, by a
# literal name and by one held in a variable
class Courier
  def ping(flags, host, port) = "Achasan via #{host}"
end
p [Courier.new, socks[0]].map { |x| x.send("ping", 0, "127.0.0.1", port) }
p rx.recv(32)
name = "pi" + "ng"
p [Courier.new, socks[1]].map { |x| x.send(name, 0, "127.0.0.1", port) }
p rx.recv(32)

# a value with no method of that name raises Object#send's NoMethodError,
# which names the payload
begin
  [1, socks[0]].each { |x| x.send("Children's Grand Park", 0, "127.0.0.1", port) }
rescue NoMethodError => e
  puts e.message.tr("`", "'")
end
[rx, tx, *socks].each(&:close)
