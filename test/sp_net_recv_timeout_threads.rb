# spinel: not-cruby -- the spinel-native FFI DSL; the .expected is authored
# sp_net_recv_some_timeout under threads: the read parks its green thread with
# the deadline (sp_sched_wait_io_timeout), so other threads run while it
# waits, a reply that arrives in time wakes it, and silence ends it at the
# deadline.
require "tmpdir"

module Net
  ffi_func :sp_net_unix_listen,        [:str, :int],          :int
  ffi_func :sp_net_unix_connect,       [:str],                :int
  ffi_func :sp_net_accept,             [:int],                :int
  ffi_func :sp_net_set_nonblock,       [:int],                :int
  ffi_func :sp_net_write_str,          [:int, :str],          :int
  ffi_func :sp_net_recv_some_timeout,  [:int, :int, :double], :binstr
  ffi_func :sp_net_take_recv_timeout,  [],                    :int
  ffi_func :sp_net_close,              [:int],                :int
end

path = File.join(Dir.tmpdir, "sp_net_rtt_#{Process.pid}.sock")
File.unlink(path) if File.exist?(path)
lfd = Net.sp_net_unix_listen(path, 4)
quiet_c = Net.sp_net_unix_connect(path)
quiet_a = Net.sp_net_accept(lfd)
busy_c = Net.sp_net_unix_connect(path)
busy_a = Net.sp_net_accept(lfd)
Net.sp_net_set_nonblock(quiet_c)
Net.sp_net_set_nonblock(busy_c)

# Starting a thread first starts the scheduler's monitor, so the reads below
# park rather than fall back to a plain blocking poll.
Thread.new { 1 }.join

silent = Thread.new do
  got = Net.sp_net_recv_some_timeout(quiet_c, 64, 0.3)
  [got, Net.sp_net_take_recv_timeout]
end

answered = Thread.new do
  got = Net.sp_net_recv_some_timeout(busy_c, 64, 10.0)
  [got, Net.sp_net_take_recv_timeout]
end

# The main thread keeps running while both readers wait, and answers one.
sleep 0.05
Net.sp_net_write_str(busy_a, "hello")

r = answered.value
puts "answered: #{r[0].inspect} timed out: #{r[1]}"
r = silent.value
puts "silent: #{r[0].inspect} timed out: #{r[1]}"

Net.sp_net_close(quiet_a)
Net.sp_net_close(quiet_c)
Net.sp_net_close(busy_a)
Net.sp_net_close(busy_c)
Net.sp_net_close(lfd)
File.unlink(path)
