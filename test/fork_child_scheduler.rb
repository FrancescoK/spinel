# spinel: not-cruby
# A fork after threads have started leaves the child a sound scheduler: the
# thread that forked goes on, the others are gone (as CRuby's child keeps
# only the forking thread), and the child's own threads sleep, wait, take a
# Mutex and are joined, through collections. Before, the child inherited the
# parent's "monitor started" flag but not the monitor, so its first sleep
# never woke (#10516). A fork from a thread other than the main thread is
# refused. (ffi_func is spinel's own; this .expected is written by hand from
# what CRuby answers for the same steps through Process.fork.)
module Sys
  ffi_func :sp_net_fork,     [],     :int
  ffi_func :sp_net_wait_any, [],     :int
  ffi_func :sp_net_exit,     [:int], :int
end

q = Queue.new
m = Mutex.new
looper = Thread.new { loop { sleep(0.05) } }
waiter = Thread.new { q.pop }
sleep(0.1)

def child_work(tag, q, m, looper, waiter)
  out = []
  out << "#{tag} looper alive: #{looper.alive?}"
  out << "#{tag} waiter alive: #{waiter.alive?}"
  q << :for_nobody                       # the parent's waiter is not woken here
  out << "#{tag} queue size: #{q.size}"
  cq = Queue.new
  t = Thread.new { sleep(0.05); cq << :ping; m.synchronize { :locked } }
  out << "#{tag} popped #{cq.pop}"
  out << "#{tag} joined #{t.value}"
  junk = []
  20_000.times { |i| junk << "s#{i}" * 3 }   # collections in the child
  out << "#{tag} junk #{junk.size}"
  ts = (1..3).map { |i| Thread.new(i) { |k| sleep(0.01 * k); k * 10 } }
  out << "#{tag} values #{ts.map(&:value).inspect}"
  out
end

2.times do |n|
  $stdout.flush
  pid = Sys.sp_net_fork
  if pid == 0
    child_work("child#{n}", q, m, looper, waiter).each { |l| puts l }
    $stdout.flush
    Sys.sp_net_exit(0)
  end
  Sys.sp_net_wait_any
  puts "parent: child#{n} exited"
end
puts "parent looper alive: #{looper.alive?}"
q << :done
puts "parent waiter got: #{waiter.value}"

t = Thread.new do
  begin
    Sys.sp_net_fork
    :forked
  rescue NotImplementedError => e
    e.message
  end
end
puts "from a thread: #{t.value}"
