# The FIRST Thread.current[...] write allocates the thread's TLS map and stores
# it into the thread, and that store is a second reference the barrier did not
# cover. sp_Thread_tls_set records the MAP after filling it, which is what
# #4311's leg checks, but nothing recorded the THREAD for `t->tls = m` -- and
# the allocation of the map is itself a point that can collect, which clears
# the dirty bit of a thread that had already survived a cycle. A minor mark
# does not walk the old list, so the whole map was swept and the next read
# answered nil.
#
# The thread has to still be alive at the read: a thread that has terminated
# gets recorded on the way out of run_thread_once (#4378), which covers this
# store by accident. So it writes its slot, hands the main thread the baton,
# and parks. Under SPINEL_GC_MINOR=1 this printed nil in 8 runs out of 10
# before the fix, and does not print it at all after.
# spinel: gc-minor
ready = Queue.new
go = Queue.new
t = Thread.new do
  acc = 0
  i = 0
  while i < 200_000
    acc += ("fill-" + i.to_s).length
    i += 1
  end
  Thread.current[:k] = "answer-" + acc.to_s
  ready.push(1)
  go.pop
  nil
end
ready.pop

i = 0
sink = 0
while i < 300_000
  sink += ("churn-" + i.to_s).length
  i += 1
end
p t[:k]
go.push(1)
t.join
p sink > 0
