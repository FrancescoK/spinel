# A thread that first ran in one of main's Thread.pass sweeps is pinned to
# main's worker, and the readiness of what it waits on is delivered only
# when main drains its own readiness set. Main's pump did that; a
# Thread.pass loop did not, so main spinning on Thread.pass until such a
# thread got its bytes spun for good (a test with two acceptors hung on
# macOS about one run in forty).
rounds = 0
20.times do
  r, w = IO.pipe
  t = Thread.new { r.read(1) }
  Thread.pass until t.status == "sleep"
  w.write("x")
  Thread.pass while t.alive?
  rounds += 1 if t.value == "x"
  r.close
  w.close
end
p rounds
