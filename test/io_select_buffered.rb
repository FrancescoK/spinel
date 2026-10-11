# IO.select answers an IO whose input stdio already buffered: a #gets took
# both lines off the socket, so its descriptor is empty, yet the second line
# is readable. CRuby answers at once; Spinel waited out the timeout.
require "socket"

pair = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM, 0)
a = pair[0]
idle = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM, 0)[0]
pair[1].write("one\ntwo\n")
p a.gets

started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
ready = IO.select([idle, a], nil, nil, 5)
p ready[0] == [a]
p Process.clock_gettime(Process::CLOCK_MONOTONIC) - started < 1
p a.gets

# drained: the descriptor and the buffer are both empty, so the timeout runs
p IO.select([a], nil, nil, 0)
