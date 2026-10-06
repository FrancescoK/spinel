# A green thread parked reading inside a begin, several frames deep, is woken
# by a close from another thread while a second green thread on the same
# worker sits inside a begin of its own, at the same handler index but a
# shallower GC-root depth. The rescue must restore the first thread's own
# root watermark: the watermarks are per worker like the handler arms, and
# before they travelled with the exception context (#4546) the rescue
# restored the second thread's, dropping the roots of the frames above it,
# so the next collection freed strings those frames still held. One worker
# (SPINEL_WORKERS, read when the first thread starts) puts both threads on
# the same arms; CRuby ignores it.
ENV["SPINEL_WORKERS"] = "1"
require 'socket'
$stdout.sync = true
Thread.report_on_exception = false
srv = TCPServer.new('127.0.0.1', 0)
port = srv.addr[1]

# each level holds a string of its own across the park below it
def park(sock, depth)
  held = "held-#{depth}" * 4
  if depth == 0
    r = begin
      sock.readpartial(64)
    rescue IOError => e
      e.message
    end
    GC.start
    junk = Array.new(300) { |k| "junk-#{k}" * 4 }
    ok = junk.size == 300
  else
    r, ok = park(sock, depth - 1)
  end
  [r, ok && held == "held-#{depth}" * 4]
end

def shallow_waiter(rd)
  Thread.new do
    begin
      rd.read(1)
    rescue IOError
      nil
    end
  end
end

def parked(t)
  Thread.pass while t.status == "run"
end

ROUNDS = 50
good = 0
ROUNDS.times do
  a = TCPSocket.new('127.0.0.1', port)
  b = srv.accept
  deep = Thread.new { park(b, 8) }
  parked(deep)
  rd, wr = IO.pipe
  shallow = shallow_waiter(rd)
  parked(shallow)
  b.close
  good += 1 if deep.value == ["stream closed in another thread", true]
  wr.close
  shallow.value
  rd.close
  a.close
end
puts "held strings intact in #{good} of #{ROUNDS} rounds"
