# Two threads accept on one server; one connection arrives, so one of them
# gets it and the other, having seen the server readable, finds nothing to
# take and waits for the next connection. A close of the server from the
# main thread then has to end that wait with IOError, as CRuby's does. The
# waiting accept held the server's stream so the close could not release it
# under it, and the close's wakeup only sent it back to wait again: the
# program hung. Before that it answered Errno::ECONNREFUSED.
require 'socket'
Thread.report_on_exception = false
ends = Hash.new(0)
20.times do
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
