# Without the event backend (SPINEL_SCHED_POLL, set here before any thread
# waits) a thread waiting on a descriptor is woken by the monitor's poll(),
# and a close from another thread did not wake it. While no thread used the
# stream, the close gave the descriptor back and poll() reported it invalid.
# But a waiter can hold the stream: here two threads accept on one server,
# one connection arrives, and the one that loses it waits for the next one
# holding the server's stream. The close then left the descriptor open for
# it, poll() had nothing to report, and the waiter and the close waited for
# good. The close has to end that wait with IOError, as CRuby's does.
# (CRuby ignores the variable.)
require 'socket'
ENV["SPINEL_SCHED_POLL"] = "1"
Thread.report_on_exception = false
ends = Hash.new(0)
10.times do
  srv = TCPServer.new('127.0.0.1', 0)
  port = srv.addr[1]
  acceptors = Array.new(2) do
    Thread.new do
      srv.accept
    rescue StandardError => e
      e
    end
  end
  Thread.pass until acceptors.all? { |t| t.status == "sleep" }
  c = TCPSocket.new('127.0.0.1', port)
  Thread.pass until acceptors.any? { |t| !t.alive? }
  sleep 0.01
  srv.close
  acceptors.each do |t|
    v = t.value
    ends[v.is_a?(Exception) ? v.class : :socket] += 1
    v.close unless v.is_a?(Exception)
  end
  c.close
end
p ends.sort_by { |k, _| k.to_s }
