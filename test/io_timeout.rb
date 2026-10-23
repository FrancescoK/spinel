require "socket"
require "io/wait"

class TimeoutMethodOwner
  attr_reader :timeout

  def timeout=(value)
    @timeout = value
    :stored
  end
end

def result(label)
  value = yield
  puts "#{label}: #{value.inspect}"
rescue => error
  puts "#{label}: #{error.class}: #{error.message}"
end

def close_pair(left, right)
  left.close unless left.closed?
  right.close unless right.closed?
end

def timeout_receiver(io, events)
  events << "receiver"
  io
end

def timeout_argument(events)
  events << "argument"
  0.04
end

def delayed_read(method, timeout)
  left, right = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM, 0)
  left.timeout = timeout
  producer = Thread.new do
    sleep 0.15
    right.write("OK")
    right.close
  rescue IOError, SystemCallError
  end
  result(method) do
    method == "read-all" ? left.read : method == "readpartial" ? left.readpartial(1) : left.read(1)
  end
  producer.join
ensure
  close_pair(left, right)
end

puts IO::TimeoutError.superclass
left, right = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM, 0)
result("default") { left.timeout }
[nil, false, 0, 0.01, 1, Rational(1, 10)].each do |value|
  result("setter-self") { left.public_send(:timeout=, value).equal?(left) }
  result("getter") { left.timeout }
end
[-1, -Float::INFINITY, Float::INFINITY, Float::NAN, true, "0.01", Object.new].each do |value|
  result("invalid") { left.public_send(:timeout=, value) }
  result("retained") { left.timeout }
end
result("assignment") { left.timeout = 0.02 }
events = []
result("assignment-effect") { timeout_receiver(left, events).timeout = timeout_argument(events) }
result("assignment-order") { events }
left.timeout = 0.02
mixed = [left, "other"]
result("boxed-getter") { mixed[0].timeout }
result("boxed-setter") { mixed[0].public_send(:timeout=, 0.02).equal?(left) }
[left, TimeoutMethodOwner.new].each do |object|
  result("method-assignment") { object.timeout = 0.02 }
  result("method-getter") { object.timeout }
  result("method-setter") { object.public_send(:timeout=, 0.02).equal?(object) }
end
copy = left.dup
result("dup") { copy.timeout }
copy.close
left.freeze
result("frozen") { left.public_send(:timeout=, 0.03).equal?(left) }
left.close
result("closed-get") { left.timeout }
result("closed-set") { left.public_send(:timeout=, nil).equal?(left) }
right.close

$stdout.timeout = Rational(1, 10)
GC.start
result("stdout-root") { $stdout.timeout }
$stdout.timeout = nil

delayed_read("read", 0.02)
delayed_read("read-all", 0.02)
delayed_read("readpartial", 0.02)
delayed_read("nil-read", nil)

left, right = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM, 0)
left.timeout = 0.02
result("read-zero") { left.read(0) }
result("partial-zero") { left.readpartial(0) }
right.write("X")
left.timeout = 0
result("zero-ready") { left.read(1) }
result("zero-timeout") { left.read(1) }
close_pair(left, right)

left, right = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM, 0)
left.timeout = 0.02
right.write("L\nR")
left.gets
result("buffered-wait") { left.wait_readable }
result("buffered-priority") { left.wait_priority }
result("buffered-wait-call") { left.wait(0.02, :read) }
result("buffered-wait-nil") { left.wait(nil, :read) }
result("buffered-wait-negative") { left.wait(-1, :read) }
result("buffered-negative") { left.wait_readable(-1) }
left.timeout = false
result("buffered-false") { left.wait_readable }
left.timeout = 0.02
result("buffered-byte") { left.read(1) }
close_pair(left, right)

left, right = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM, 0)
# each byte comes well inside the timeout, the three together after it: a
# wait that makes progress starts its timeout again (a 0.05s gap under a
# 0.1s timeout timed out on a loaded macOS runner)
left.timeout = 0.6
producer = Thread.new do
  3.times do
    sleep 0.25
    right.write("X")
  end
  right.close
end
result("progress") { left.read(3) }
producer.join
close_pair(left, right)

left, right = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM, 0)
left.timeout = 0.02
result("wait-default") { left.wait_readable }
result("writable-default") { left.wait_writable.equal?(left) }
result("wait-nil") { left.wait_readable(nil) }
result("wait-short") { left.wait_readable(0.005) }
result("wait-long-empty") { left.wait_readable(0.03) }
producer = Thread.new do
  sleep 0.08
  right.write("R")
end
result("wait-override") { left.wait_readable(0.5).equal?(left) }
producer.join
result("ready-byte") { left.read(1) }
result("select") { IO.select([left], nil, nil, 0.03) }
producer = Thread.new do
  sleep 0.08
  right.write("S")
end
result("select-override") { !IO.select([left], nil, nil, 0.5).nil? }
producer.join
result("select-byte") { left.read(1) }
close_pair(left, right)

left, right = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM, 0)
left.timeout = 0.02
left.setsockopt(Socket::SOL_SOCKET, Socket::SO_SNDBUF, 4096)
consumer = Thread.new do
  sleep 0.15
  right.read
end
result("write") { left.write("X" * (1024 * 1024)) }
left.close
consumer.join
right.close

left, right = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM, 0)
left.timeout = 0.5
closer = Thread.new do
  sleep 0.03
  left.close
end
result("close-wakes-read") { left.read(1) }
closer.join
right.close

left, right = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM, 0)
left.timeout = 0.5
closer = Thread.new do
  sleep 0.03
  left.close
end
result("close-wakes-wait") { left.wait_readable }
closer.join
right.close

left, right = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM, 0)
left.timeout = 0.5
reader = Thread.new do
  result("raise-wakes-read") { left.read(1) }
end
sleep 0.03
reader.raise(RuntimeError, "injected")
reader.join
close_pair(left, right)

begin
  raise IO::TimeoutError, "explicit"
rescue IOError => error
  puts "rescue: #{error.class}: #{error.message}"
end
