# A Signal.trap proc ran inside the C signal handler, on top of whatever the
# program was doing when the signal landed. A signal sent from outside while
# the program was inside malloc or the collector ran Ruby on a half-updated
# heap: this trap, which allocates, aborted on glibc's heap checks every run.
# The handler now only records the delivery, and the proc runs where Ruby may
# run, as CRuby's does: at the program's next safe point, and during a sleep
# or a blocking read, which then go on.
$hits = 0
$keep = []
Signal.trap(:USR1) do
  $hits += 1
  s = +"t"
  s << "x" * (100 + $hits % 300)
  $keep << s
  $keep.shift if $keep.size > 50
end
pid = Process.pid
sender = Process.spawn("sh", "-c", "i=0; while [ $i -lt 3000 ]; do kill -USR1 #{pid} || exit 0; i=$((i+1)); done")
acc = []
n = 0
t0 = Time.now
while Time.now - t0 < 1.5
  a = +"m"
  a << "y" * (n % 500)
  acc << a
  acc << [n, a.dup, { k: a }]
  acc.clear if acc.size > 2000
  n += 1
end
Process.wait(sender)
puts "storm survived"
p $hits > 0

# a trap during a sleep runs, and the sleep lasts as long as it was asked to
$ran = []
Signal.trap(:USR2) { $ran << :usr2 }
kicker = Process.spawn("sh", "-c", "sleep 0.1; kill -USR2 #{pid}")
t = Time.now
sleep 0.5
p $ran
p Time.now - t >= 0.45
Process.wait(kicker)

# and during a read that is waiting for its bytes
r, w = IO.pipe
kicker = Process.spawn("sh", "-c", "sleep 0.1; kill -USR2 #{pid}; sleep 0.2; printf x", out: w)
w.close
p r.read(1)
p $ran
Process.wait(kicker)
r.close
