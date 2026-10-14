# A close from another thread can land while a thread is inside a read or a
# write of the same socket rather than parked on it. The close released the
# FILE and its descriptor at once, so that thread could read the freed
# FILE's buffer, or call read(2) or send(2) on a descriptor number the next
# connection had already been given: it took that connection's bytes, or
# sent its own down it. Now the FILE and the number stay the thread's until
# it leaves the read or write. Each round closes a socket under a busy
# reader and a busy writer and at once opens a new connection, which takes
# the number the close gave back, and sends bytes of its own: the reader
# sees only its peer's bytes, the new connection receives nothing, and both
# threads end with IOError.
require 'socket'
Thread.report_on_exception = false

srv = TCPServer.new('127.0.0.1', 0)
port = srv.addr[1]

ROUNDS = 40
foreign = 0
leaked = 0
reader_ends = Hash.new(0)
writer_ends = Hash.new(0)
ROUNDS.times do
  a = TCPSocket.new('127.0.0.1', port)
  b = srv.accept
  started = Queue.new
  feeder = Thread.new do
    loop { a.write("a" * 512) }
  rescue StandardError
    nil
  end
  reader = Thread.new do
    got = +''
    begin
      loop do
        got << b.readpartial(4096)
        started << 1 if started.empty?
      end
    rescue StandardError => e
      [got, e.class]
    end
  end
  writer = Thread.new do
    loop { b.write("b" * 512) }
  rescue StandardError => e
    e.class
  end
  started.pop
  b.close
  c = TCPSocket.new('127.0.0.1', port)
  d = srv.accept
  c.write("z" * 512)
  got, ended = reader.value
  foreign += 1 unless got.delete('a').empty?
  reader_ends[ended] += 1
  writer_ends[writer.value] += 1
  leaked += 1 unless c.read_nonblock(4096, exception: false) == :wait_readable
  a.close
  feeder.join
  c.close
  d.close
end
puts "#{ROUNDS} rounds"
p foreign
p leaked
p reader_ends
p writer_ends
