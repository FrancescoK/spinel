# A green thread run from inside a Fiber ends back in that Fiber. When the
# main thread had entered the Fiber by #transfer, a thread that ended during
# a Thread.pass sweep went where the Fiber would return to instead: the root
# (whose #transfer then answered early) or a resumed Fiber (a crash).

# entered from the root by #transfer
x = Fiber.new do
  t = Thread.new { :fin }
  Thread.pass while t.alive?
  p t.value
  :xdone
end
p x.transfer

# a thread that passes and sleeps before it ends
x = Fiber.new do
  t = Thread.new { Thread.pass; sleep 0.01; :slept }
  Thread.pass while t.alive?
  p t.value
  :x2done
end
p x.transfer

# entered by #transfer from a resumed Fiber, which it transfers back to
a = Fiber.new do
  y = Fiber.new do
    t = Thread.new { 2.times { Thread.pass }; :fin2 }
    Thread.pass while t.alive?
    p t.value
    a.transfer(:ydone)
  end
  r = y.transfer
  p [:a_got, r]
  :adone
end
p a.resume

# a thread's own transfers end in the thread, not in the Fiber that ran it
f = Fiber.new do
  t = Thread.new do
    tr = Fiber.current
    x = Fiber.new { |v| tr.transfer(v + 1); :fin }
    [x.transfer(1), x.transfer, Fiber.new { :only }.transfer]
  end
  Thread.pass while t.alive?
  t.value
end
p f.resume
p :done
