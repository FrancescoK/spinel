# A SIGINT that arrives while the program recurses with no loop: the
# recursive method is on a cycle of the call graph and polls at its entry
# (#9222). The call graph follows a call to the methods its plan reaches
# (#9377), so `self[n - 1]` reaches this `[]` and `@log[0]`, an Array's,
# reaches none; the recursion still polls.
$stdout.sync = true
pid = Process.pid
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
class Fib
  def initialize = @log = [0]
  def [](n)
    @log << n if n < @log[0]
    n < 2 ? n : self[n - 1] + self[n - 2]
  end
end
begin
  p Fib.new[60]
rescue Interrupt
  puts "recursion interrupted"
end
