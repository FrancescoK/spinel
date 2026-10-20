# A SIGINT that arrives while the program runs a counting iterator whose
# block only computes on scalars (Math included): the loop carries no poll
# and is marked as a region where the signal is raised where it lands
# (sp_sig_async_ok), as a pure while is. The second loop is interrupted too.
$stdout.sync = true
pid = Process.pid
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}; sleep 0.3; kill -INT #{pid}")
s = 0
begin
  (1..4_000_000_000).each { |i| s = (s + i % 7) & 0xffff }
rescue Interrupt
  puts "each interrupted"
end
f = 0.0
begin
  4_000_000_000.times { |i| f = Math.sqrt(f + i.to_f) }
rescue Interrupt
  puts "times interrupted"
end
