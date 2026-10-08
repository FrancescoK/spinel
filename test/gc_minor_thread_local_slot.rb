# A value stored into Thread.current[...] is held by the thread's TLS MAP, and
# the write barrier was pointed at the THREAD instead. A minor mark then reached
# the map through the thread's scan and marked it, but an old object is not
# re-scanned unless it is in the remembered set -- so a young value stored into
# a long-lived map was swept out from under it, and the next read faulted
# (#4311). `Thread.current[:slots] = {}` per request, on a main thread whose map
# has been alive since boot, is that shape.
#
# The fiber is load-bearing: it is what keeps the value off the C stack between
# the write and the read, so the map is the only thing holding it. Run under
# SPINEL_GC_MINOR=1 this segfaulted on this program within a few rounds.
# spinel: gc-minor
def churn(n)
  a = []
  n.times { a << ("x" * 200) }
  a.length
end

t = Thread.new { 1 }
t.join

Thread.current[:seed] = "keep the map alive"
churn(30000)          # the map survives a collection: it is old now

ok = 0
bad = 0
120.times do |round|
  f = Fiber.new do
    Thread.current[:slots] = {}
    Fiber.yield
    h = Thread.current[:slots]
    h["a"] = "value #{round}"
    Fiber.yield
    got = Thread.current[:slots]
    if got["a"] == "value #{round}"
      ok += 1
    else
      bad += 1
    end
  end
  f.resume
  churn(1500)
  f.resume
  churn(1500)
  f.resume
end
p [ok, bad]

# Thread#name= writes into the thread itself, which for the MAIN thread is a
# static: the barrier reads the byte in front of it to decide whether there is
# a header, so it needs the same skip guard the root fiber has.
Thread.current.name = "main-thread"
churn(20000)
p Thread.current.name
