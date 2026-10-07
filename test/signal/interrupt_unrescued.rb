# An Interrupt nothing rescues: the ensure runs, then the process ends by SIGINT (#7202).
$stdout.sync = true
begin
  Process.kill("INT", Process.pid)
  sleep 5
ensure
  puts "ensure ran"
end
puts "not reached"
