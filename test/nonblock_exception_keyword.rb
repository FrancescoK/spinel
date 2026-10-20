# A *_nonblock call's keywords, as CRuby reads them. An `exception:` switch
# held in a variable answers the wait marker when it is false, as a literal
# false does: the arms took any switch but a literal false for true and
# raised. IO's read_nonblock and write_nonblock take true or false alone
# (ArgumentError otherwise), and a socket call raises for anything but false.
# A keyword other than `exception:` raises ArgumentError once the keyword
# values have run, before anything is read or written; it was ignored.
# Typed and boxed receivers.
require "socket"

quiet = ARGV.size > 5   # false, known only at run time
loud = !quiet
$ran = []

def note(v)
  $ran << v
  v
end

def try(label)
  $ran.clear
  puts "#{label}: #{yield.inspect}"
rescue IO::WaitReadable, IO::WaitWritable, EOFError => e
  puts "#{label}: #{e.class}"
rescue ArgumentError => e
  puts "#{label}: ArgumentError: #{e.message} (ran #{$ran.inspect})"
end

a, b = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM)
try("recv_nonblock quiet") { b.recv_nonblock(32, exception: quiet) }
try("recv_nonblock loud") { b.recv_nonblock(32, exception: loud) }
try("recv_nonblock nil") { b.recv_nonblock(32, exception: nil) }
[b].each { |s| try("boxed recv_nonblock quiet") { s.recv_nonblock(32, exception: quiet) } }
a.write("Seongsu Bridge")
try("recv_nonblock quiet, data waiting") { b.recv_nonblock(32, exception: quiet) }
a.write("Jayang-dong")
[b].each { |s| try("boxed recv_nonblock quiet, data waiting") { s.recv_nonblock(32, exception: quiet) } }
a.write("Achasan")
try("recv_nonblock seongsu:") { b.recv_nonblock(32, seongsu: note(1)) }
[b].each { |s| try("boxed recv_nonblock exception: false, jayang:") { s.recv_nonblock(32, exception: note(false), jayang: note(2)) } }
try("recv_nonblock, the data still waiting") { b.recv_nonblock(32) }
opts = { exception: quiet }
try("recv_nonblock **opts") { b.recv_nonblock(32, **opts) }
odd = { exception: false, mangwon: 3, hapjeong: 4 }
try("recv_nonblock **odd") { b.recv_nonblock(32, **odd) }

r, w = IO.pipe
try("read_nonblock quiet") { r.read_nonblock(32, exception: quiet) }
try("read_nonblock nil") { r.read_nonblock(32, exception: nil) }
[r].each { |io| try("boxed read_nonblock quiet") { io.read_nonblock(32, exception: quiet) } }
[r].each { |io| try("boxed read_nonblock 1") { io.read_nonblock(32, exception: 1) } }
try("write_nonblock gimpo:") { w.write_nonblock("Kondae", gimpo: note(5)) }
[w].each { |io| try("boxed write_nonblock incheon:, gimpo:") { io.write_nonblock("Kondae", incheon: note(6), gimpo: note(7)) } }
try("read_nonblock, nothing written") { r.read_nonblock(32, exception: false) }
w.write("Kondae")
try("read_nonblock jamsil:") { r.read_nonblock(32, jamsil: note(8)) }
try("read_nonblock quiet, data waiting") { r.read_nonblock(32, exception: quiet) }
loop { break if w.write_nonblock("Achasan " * 512, exception: false) == :wait_writable }
try("write_nonblock quiet, pipe full") { w.write_nonblock("Achasan", exception: quiet) }
try("write_nonblock loud, pipe full") { w.write_nonblock("Achasan", exception: loud) }
[w].each { |io| try("boxed write_nonblock quiet, pipe full") { io.write_nonblock("Achasan", exception: quiet) } }
[w].each { |io| try("boxed write_nonblock nil") { io.write_nonblock("Achasan", exception: nil) } }
w.close
loop { break unless r.read_nonblock(65536, exception: false).is_a?(String) }
try("read_nonblock quiet, at EOF") { r.read_nonblock(32, exception: quiet) }
try("read_nonblock loud, at EOF") { r.read_nonblock(32, exception: loud) }

server = TCPServer.new("127.0.0.1", 0)
try("accept_nonblock quiet") { server.accept_nonblock(exception: quiet) }
try("accept_nonblock nil") { server.accept_nonblock(exception: nil) }
[server].each { |s| try("boxed accept_nonblock quiet") { s.accept_nonblock(exception: quiet) } }
[server].each { |s| try("boxed accept_nonblock children:") { s.accept_nonblock(children: note(9)) } }
sa = Socket.sockaddr_in(server.addr[1], "127.0.0.1")
c1 = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
puts "connect_nonblock quiet: #{c1.connect_nonblock(sa, exception: quiet).inspect}"
c2 = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
begin
  c2.connect_nonblock(sa, exception: nil)
rescue IO::WaitWritable => e
  puts "connect_nonblock nil: #{e.class}"
end
c3 = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
[c3].each { |s| puts "boxed connect_nonblock quiet: #{s.connect_nonblock(sa, exception: quiet).inspect}" }
c4 = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
begin
  c4.connect_nonblock(sa, hangang: 10)
rescue ArgumentError => e
  puts "connect_nonblock hangang:: #{e.message}"
end
a.close
[b].each { |s| try("boxed recv_nonblock quiet, at EOF") { s.recv_nonblock(32, exception: quiet) } }
[b, r, server, c1, c2, c3, c4].each(&:close)
