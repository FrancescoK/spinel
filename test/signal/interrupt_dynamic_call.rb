# A SIGINT that arrives while the program recurses through a proc's call:
# twice makes the call, which may reach any method, and polls at its entry
# (#9222); fib, which only calls twice, need not. twice yields, so its body
# runs spliced into fib, and fib polls for it.
$stdout.sync = true
pid = Process.pid
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
$f = ->(n) { fib(n) }
def twice(n)
  yield n
  n < 2 ? n : $f.call(n - 1) + $f.call(n - 2)
end
def fib(n) = twice(n) { |x| x }
begin
  p fib(60)
rescue Interrupt
  puts "dynamic call interrupted"
end
