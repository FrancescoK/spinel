# A listening socket held in a boxed slot -- an IO.select result, or an
# Array built with a splat beside a pipe -- still answers its server
# methods: to_io, accept and accept_nonblock (with and without
# `exception: false`). WEBrick's accept loop takes each server out of the
# IO.select result and calls `svr.to_io.accept_nonblock(exception: false)`;
# the boxed IO arm knew the stream methods only, so each of these raised
# NoMethodError naming TCPServer.
require "socket"

def connect(port, msg)
  Thread.new { c = TCPSocket.new("127.0.0.1", port); c.write(msg); c.close }
end

listeners = [TCPServer.new("127.0.0.1", 0)]
port = listeners[0].addr[1]
r, w = IO.pipe
mixed = [r, *listeners]

# nothing pending: the marker, not an exception
p mixed[1].to_io.accept_nonblock(exception: false)
begin
  mixed[1].accept_nonblock
rescue IO::WaitReadable => e
  p e.is_a?(IO::WaitReadable)
end
p mixed[1].to_io.equal?(listeners[0])

t = connect(port, "one\n")
if ready = IO.select(mixed, nil, nil, 5)
  p ready[0].size
  ready[0].each do |svr|
    sock = svr.to_io.accept_nonblock(exception: false)
    p sock == :wait_readable
    p sock.gets
    sock.close
  end
end
t.join

t = connect(port, "two\n")
ready = IO.select(listeners, nil, nil, 5)
s = ready[0][0].accept
p s.gets
s.close
t.join

t = connect(port, "three\n")
ready = IO.select(listeners, nil, nil, 5)
s = ready[0][0].accept_nonblock
p s.gets
s.close
t.join

w.close
r.close
listeners.each(&:close)
p :done
