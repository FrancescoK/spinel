# #9222's reproducer: a SIGINT lands at a random point of a loop that
# allocates, often inside malloc or the collector. The raise waits for the
# loop's next poll, so the rescue and the ensure, which allocate, run on a
# whole heap: CRuby prints these two lines every time.
acc = []
pid = Process.pid
begin
  Process.spawn("sh", "-c", "sleep 0.3; kill -INT #{pid}")
  n = 0
  loop do
    a = +"m"
    a << "y" * (n % 500)
    acc << [n, a.dup, { k: a }]
    acc.clear if acc.size > 2000
    n += 1
  end
rescue Interrupt
  s = +"r"
  50.times { s << "z" * 100 }
  puts "rescued #{s.size}"
ensure
  t = (1..1000).map { |i| "e#{i}" }.join(",")
  puts "ensure #{t.size}"
end
