# Kernel#exec replaces the process with the command, read as spawn reads it,
# and raises the Errno a failed exec gives (#7203).
begin
  exec "/nonexistent_spinel_exec_target"
rescue SystemCallError => e
  puts e.class
  puts e.message
end
pid = spawn("echo", "spawned")
Process.wait(pid)
$stdout.flush
exec "echo", "replaced", "by", "echo"
puts "never printed"
