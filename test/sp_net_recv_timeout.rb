# spinel: not-cruby -- the spinel-native FFI DSL; the .expected is authored
# sp_net_recv_some_timeout: a read with a deadline. sp_net_recv_some waits
# for the first byte forever, so a client whose server never answers parks
# for good. The timed read gives up after timeout_s seconds, and
# sp_net_take_recv_timeout tells that apart from EOF, which also reads as "".
#
# A UNIX-domain pair gives two live fds without binding a port. The fds stay
# blocking: the deadline has to hold there too.
require "tmpdir"

module Net
  ffi_func :sp_net_unix_listen,        [:str, :int],          :int
  ffi_func :sp_net_unix_connect,       [:str],                :int
  ffi_func :sp_net_accept,             [:int],                :int
  ffi_func :sp_net_write_str,          [:int, :str],          :int
  ffi_func :sp_net_recv_some_timeout,  [:int, :int, :double], :binstr
  ffi_func :sp_net_take_recv_timeout,  [],                    :int
  ffi_func :sp_net_close,              [:int],                :int
end

path = File.join(Dir.tmpdir, "sp_net_rt_#{Process.pid}.sock")
File.unlink(path) if File.exist?(path)
lfd = Net.sp_net_unix_listen(path, 4)
cfd = Net.sp_net_unix_connect(path)
afd = Net.sp_net_accept(lfd)
puts "paired: #{lfd > 0 && cfd > 0 && afd > 0}"

# Nothing sent: the read gives up on the deadline instead of waiting forever.
t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
got = Net.sp_net_recv_some_timeout(cfd, 64, 0.2)
waited = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0
puts "silent: #{got.inspect} timed out: #{Net.sp_net_take_recv_timeout}"
puts "waited the deadline: #{waited >= 0.15 && waited < 5.0}"
# Reading the flag clears it.
puts "cleared: #{Net.sp_net_take_recv_timeout}"

# A zero timeout is a peek.
puts "peek: #{Net.sp_net_recv_some_timeout(cfd, 64, 0.0).inspect} timed out: #{Net.sp_net_take_recv_timeout}"

# Bytes already waiting come back at once, and are not a timeout.
Net.sp_net_write_str(afd, "PONG\r\n")
puts "data: #{Net.sp_net_recv_some_timeout(cfd, 64, 5.0).inspect} timed out: #{Net.sp_net_take_recv_timeout}"

# A negative timeout waits as sp_net_recv_some does.
Net.sp_net_write_str(afd, "+OK\r\n")
puts "no deadline: #{Net.sp_net_recv_some_timeout(cfd, 64, -1.0).inspect} timed out: #{Net.sp_net_take_recv_timeout}"

# The peer closing is EOF: an empty read that did not time out.
Net.sp_net_close(afd)
puts "eof: #{Net.sp_net_recv_some_timeout(cfd, 64, 5.0).inspect} timed out: #{Net.sp_net_take_recv_timeout}"

Net.sp_net_close(cfd)
Net.sp_net_close(lfd)
File.unlink(path)
