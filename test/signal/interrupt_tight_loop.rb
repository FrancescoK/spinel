# A SIGINT that arrives while the program spins in a loop with no call and
# no wait: the handler records it, and the loop's poll raises the Interrupt
# between statements (#9222). The signal comes from a child after the loop
# has started.
$stdout.sync = true
pid = Process.pid
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
x = 0
begin
  loop { x += 1 }
rescue Interrupt
  puts "loop interrupted"
end
