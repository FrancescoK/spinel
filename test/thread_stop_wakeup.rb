# Thread.stop, Thread#wakeup / #run / #stop?, a bare sleep, and Mutex#sleep,
# as CRuby answers them. A wakeup ends Thread.stop, sleep and Mutex#sleep
# early; one that lands while the thread is still running is lost.
def t(l) = (r = yield; puts "#{l}: #{r.inspect}") rescue puts("#{l}: #{$!.class}: #{$!.message}")
def settle(th) = 300.times { break if th.status == "sleep"; sleep 0.01 }

t("stop only thread") { Thread.stop }

th = Thread.new { Thread.stop; :woke }
settle(th)
t("status while stopped") { th.status }
t("stop? while stopped") { th.stop? }
t("wakeup answers the thread") { th.wakeup.equal?(th) }
t("value") { th.value }
t("stop? when dead") { th.stop? }

th2 = Thread.new { Thread.stop; :ran }
settle(th2)
t("run answers the thread") { th2.run.equal?(th2) }
t("value after run") { th2.value }

th3 = Thread.new { t0 = Time.now; sleep 5; (Time.now - t0) < 2 }
settle(th3)
th3.wakeup
t("sleep(5) cut short") { th3.value }

th4 = Thread.new { sleep; :bare }
settle(th4)
t("bare sleep sleeps") { th4.status }
th4.wakeup
t("bare sleep woken") { th4.value }

# a wakeup before the thread stops is lost
$go = false
th5 = Thread.new { Thread.pass until $go; Thread.stop; :late }
th5.wakeup
$go = true
settle(th5)
t("early wakeup is lost") { th5.status }
th5.wakeup
t("woken later") { th5.value }

d = Thread.new {}
d.join
t("wakeup dead") { d.wakeup }
t("run dead") { d.run }

m = Mutex.new
t("Mutex#sleep timeout") { m.synchronize { m.sleep(0.05) } }
th6 = Thread.new { m.synchronize { [m.sleep, m.owned?] } }
settle(th6)
t("Mutex#sleep released the lock") { m.locked? }
th6.wakeup
t("Mutex#sleep woken") { th6.value.then { |a| [a[0].class, a[1]] } }
th7 = Thread.new { m.synchronize { m.sleep(5).class } }
settle(th7)
th7.wakeup
t("Mutex#sleep(5) woken") { th7.value }
t("Mutex#sleep unlocked") { m.sleep(0.01) }
t("Mutex#sleep negative") { m.synchronize { m.sleep(-1) } }

# the main thread is woken the same way
main = Thread.main
w = Thread.new { 300.times { break if main.status == "sleep"; sleep 0.01 }; main.wakeup; :waker }
Thread.stop
puts "main woken from stop"
w.join
w = Thread.new { 300.times { break if main.status == "sleep"; sleep 0.01 }; main.wakeup }
sleep
puts "main woken from bare sleep"
w.join
m = Mutex.new
w = Thread.new { 300.times { break if main.status == "sleep"; sleep 0.01 }; main.wakeup }
r = m.synchronize { m.sleep(10) }
puts "main woken from Mutex#sleep: #{r.class}"
w.join
