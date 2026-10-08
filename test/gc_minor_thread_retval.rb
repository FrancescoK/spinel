# Thread#value must not read a string the collector already took.
#
# run_thread_once records the thread for the write barrier on the way IN, then
# transfers to the body. The body allocates, so a collection in there clears
# every old object's dirty bit and empties the remembered set -- and the
# `t->retval = ...` store that follows the transfer then puts a young string
# into an already-old thread with nothing recording it. A minor mark never
# walks the old list, so the string is swept while the thread is holding it.
#
# A barrier before a call that can collect only covers the stores before the
# call. Deterministic: the body allocates far past the trigger (so `t` is old
# and its dirty bit has been cleared by the time the retval is stored), the
# join makes the store happen, and the churn after it is what sweeps.
# spinel: gc-minor
t = Thread.new do
  acc = 0
  i = 0
  while i < 100_000
    acc += ("fill-" + i.to_s).length
    i += 1
  end
  "answer-" + acc.to_s
end
t.join

i = 0
sink = 0
while i < 200_000
  sink += ("churn-" + i.to_s).length
  i += 1
end

p t.value
p sink > 0
