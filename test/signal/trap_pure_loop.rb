# A trapped SIGINT that arrives while the program computes only on scalars:
# a while loop, a method holding one, a counting iterator, a recursion, and a
# loop holding a counted one. Without a trap each is a region where the
# default Interrupt is raised where it lands, with no poll; a trap's proc is
# Ruby code, which runs only at a poll, so it never ran and the loop went on.
# The proc raises, and each rescue says its loop was stopped. Each loop's
# signal comes from a child started just ahead of it.
$stdout.sync = true
class Stop < StandardError; end
trap("INT") { raise Stop }
pid = Process.pid

def spin(x)
  while true; x = (x + 1) & 0xffff; end
  x
end

def fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)

Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
x = 0
begin
  while true; x = (x + 1) & 0xffff; end
rescue Stop
  puts "while stopped"
end
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
begin
  spin(x)
rescue Stop
  puts "method stopped"
end
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
s = 0
begin
  4_000_000_000.times { |i| s = (s + i % 7) & 0xffff }
rescue Stop
  puts "times stopped"
end
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
begin
  fib(90)
rescue Stop
  puts "recursion stopped"
end
Process.spawn("sh", "-c", "sleep 0.2; kill -INT #{pid}")
f = 0.0
begin
  while true
    j = 0
    while j < 1000; f = Math.sqrt(f + j.to_f); j += 1; end
  end
rescue Stop
  puts "nest stopped"
end
