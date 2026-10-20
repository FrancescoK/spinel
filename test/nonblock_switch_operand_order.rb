# A *_nonblock call whose `exception:` switch is read at run time takes its
# arguments in CRuby's order: the operands' values, then the switch's value,
# then the operands' conversions, then the switch's check. The switch went
# into the call's argument list beside the operands, where C leaves the
# order open: gcc on x86-64 checked the switch first, and an operand's
# conversion could run before the switch's value was taken.
require "socket"

$ran = []

def note(v)
  $ran << v
  v
end

class Station
  def initialize(name) = (@name = name)

  def to_s
    $ran << "to_s"
    @name
  end
end

def try(label)
  $ran.clear
  puts "#{label}: #{yield.inspect} (ran #{$ran.inspect})"
rescue TypeError, ArgumentError, IO::WaitReadable, IO::WaitWritable => e
  puts "#{label}: #{e.class} (ran #{$ran.inspect})"
end

unset = [nil, 1][0]     # nil, known only at run time
quiet = [false, 1][0]   # false, likewise

r, w = IO.pipe
try("read_nonblock, nil switch") { r.read_nonblock(note(32), exception: unset) }
try("read_nonblock, nil length and switch") { r.read_nonblock(unset, exception: unset) }
try("read_nonblock, nil length") { r.read_nonblock(unset, exception: note(quiet)) }
try("read_nonblock") { r.read_nonblock(note(32), exception: note(quiet)) }
[r].each { |io| try("boxed read_nonblock, nil length") { io.read_nonblock(unset, exception: note(quiet)) } }
try("write_nonblock, nil switch") { w.write_nonblock(Station.new("Jayang-dong"), exception: note(unset)) }
try("write_nonblock") { w.write_nonblock(Station.new("Seongsu Bridge"), exception: note(quiet)) }
[w].each { |io| try("boxed write_nonblock, nil switch") { io.write_nonblock(Station.new("Kondae"), exception: note(unset)) } }
p r.read_nonblock(64)

a, b = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM)
try("recv_nonblock, nil length") { b.recv_nonblock(unset, exception: note(quiet)) }
try("recv_nonblock") { b.recv_nonblock(note(32), exception: note(quiet)) }
s = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
try("connect_nonblock, nil address") { s.connect_nonblock(unset, exception: note(quiet)) }
[r, w, a, b, s].each(&:close)
