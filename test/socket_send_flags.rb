# A socket's send passes its flags to send(2) or sendto(2), as CRuby's does.
# They were dropped, so MSG_OOB, which a datagram socket refuses, went out
# as a plain write. The four- and the two-argument forms, on a typed
# receiver, one read out of an Array and a thread's parameter.
require "socket"

rx = UDPSocket.new
rx.bind("127.0.0.1", 0)
port = rx.addr[1]
tx = UDPSocket.new

def try(label)
  puts "#{label}: #{yield.inspect}"
rescue Errno::EOPNOTSUPP
  puts "#{label}: refused"
end

try("send MSG_OOB") { tx.send("Seongsu Bridge", Socket::MSG_OOB, "127.0.0.1", port) }
try("send MSG_DONTROUTE") { tx.send("Jayang-dong", Socket::MSG_DONTROUTE, "127.0.0.1", port) }
p rx.recv(32)
[tx].each { |s| try("boxed send MSG_OOB") { s.send("Kondae", Socket::MSG_OOB, "127.0.0.1", port) } }
[tx].each { |s| try("boxed send 0") { s.send("Achasan", 0, "127.0.0.1", port) } }
p rx.recv(32)

tx.connect("127.0.0.1", port)
try("connected send MSG_OOB") { tx.send("Han River", Socket::MSG_OOB) }
Thread.new(tx) { |s| try("thread send MSG_OOB") { s.send("Mangwon", Socket::MSG_OOB) } }.join
try("connected send 0") { tx.send("Jamsil", 0) }
p rx.recv(32)
[rx, tx].each(&:close)
