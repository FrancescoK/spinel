# Closing an IO from another thread wakes a thread parked reading it, with
# IOError, as CRuby does: the descriptor's readiness registration was
# dropped on close without readying its waiters, and a blocking read has no
# deadline, so the reader waited forever. The handle reads as closed before
# the waiters wake and carries a /dev/null sentinel instead of the freed
# FILE, so a thread mid-read when the close lands sees EOF rather than a
# NULL or the next accept's descriptor. Under connection churn the same
# program also crashed in the collector: a green thread that parked inside
# a begin and resumed after another fiber's handler sat at the same index
# restored that fiber's GC-root watermark, since the watermarks did not
# travel with the exception context (#4546, ryudoawaru).
require 'socket'
$stdout.sync = true
Thread.report_on_exception = false

srv = TCPServer.new('127.0.0.1', 0)
port = srv.addr[1]
def blocked_reader(sock)
  Thread.new do
    buf = +''
    loop { sock.readpartial(8192, buf) }
  rescue StandardError => e
    e.class.to_s + ": " + e.message
  end
end
# the reader is parked once its status is "sleep"; a fixed sleep instead
# let a loaded runner close before the read began ("closed stream") or, in
# the window between the read's own readiness probe and its registration,
# after the close had already swept the waiters (hang)
def parked(t)
  Thread.pass while t.status == "run"
end
i = 0
while i < 30
  a = TCPSocket.new('127.0.0.1', port)
  b = srv.accept
  t = blocked_reader(b)
  parked(t)
  b.close
  raise "round #{i}: #{t.value}" unless t.value == "IOError: stream closed in another thread"
  a.close
  i += 1
end
puts "close woke the reader 30 times"
p b.closed?

# the peer closing is still EOFError
a = TCPSocket.new('127.0.0.1', port)
b = srv.accept
t = blocked_reader(b)
parked(t)
a.close
p t.value
b.close

# a pipe read end closed under a reader
r, w = IO.pipe
t = Thread.new { r.gets }
parked(t)
r.close
begin
  t.value
rescue IOError => e
  puts "gets: #{e.message}"
end
w.close

# a writer parked on a full pipe whose write end is closed under it
r2, w2 = IO.pipe
t2 = Thread.new do
  begin
    w2.write("x" * 1_000_000)
  rescue IOError => e
    "write: #{e.message}"
  end
end
parked(t2)
w2.close
p t2.value
r2.close

# connection churn with two pumps per connection and a cross-thread close
# of both sockets, the shape that crashed. ITERS caps the connections as
# well as the time: uncapped, a fast machine opened several thousand in
# DUR, and when the kernel dropped a SYN (a full conntrack table) each
# such connect waited out the 1s, 2s, 4s retransmit steps, which is what
# timed the test out, not the close or the wakeups
N     = 8
DUR   = 2.0
ITERS = 200

srv = TCPServer.new('127.0.0.1', 0)
port = srv.addr[1]

def pair(srv, port)
  a = TCPSocket.new('127.0.0.1', port)
  [a, srv.accept]
end

def pump(from, to, stop)
  Thread.new do
    buf = +''
    loop { to.write(from.readpartial(8192, buf)) }
  rescue StandardError
    nil
  ensure
    stop.call
  end
end

def handler(wp, gp, lock)
  Thread.new do
    beat = Thread.new { loop { sleep 0.5 } }
    done = false
    stop = lambda do
      lock.synchronize do
        next if done

        done = true
      end
      begin wp.close; rescue StandardError; nil; end
      begin gp.close; rescue StandardError; nil; end
    end
    a = pump(wp, gp, stop)
    b = pump(gp, wp, stop)
    [a, b].each(&:join)
  ensure
    beat&.kill
  end
end

live = []
blob = 'z' * 4096
deadline = Time.now + DUR
iters = 0

while Time.now < deadline && iters < ITERS
  iters += 1
  while live.size < N
    wc, wp = pair(srv, port)
    gp, gg = pair(srv, port)
    live << { wc: wc, gg: gg, th: handler(wp, gp, Mutex.new) }
  end
  live.each { |c| begin c[:gg].write(blob); rescue StandardError; nil; end }
  ready = IO.select(live.map { |c| c[:wc] }, nil, nil, 0.01)
  ready[0].each { |s| begin s.read_nonblock(65_536); rescue StandardError; nil; end } if ready
  live.shift(2).each do |c|
    begin c[:wc].close; rescue StandardError; nil; end
    begin c[:gg].close; rescue StandardError; nil; end
  end
end
# every handler winds down through the peer close and the cross-thread
# close its stop lambda does, so nothing is parked at exit
live.each do |c|
  begin c[:wc].close; rescue StandardError; nil; end
  begin c[:gg].close; rescue StandardError; nil; end
  c[:th].join
end
puts 'churn survived'
