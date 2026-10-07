# A method's &block tested for truthiness inside a Thread or Fiber body it
# starts: present exactly when the caller gave one (webrick's start_thread
# runs `block ? block.call(sock) : run(sock)` in its request thread)
def t1(&block) = Thread.new { block ? :given : :none }.value
def t2(&block) = Thread.new { if block then block.call(1) else :none end }.value
def f1(&block) = Fiber.new { block ? :given : :none }.resume
def t3(x, &block)
  Thread.new { block ? block.call(x) : "run #{x}" }.value
end
def both(&block)
  r = yield 5
  [r, Thread.new { block ? :given : :none }.value]
end
p t1, t1 {}, t2, t2 { |v| v + 1 }, f1, f1 {}
p t3(1), t3(2) { |v| "blk #{v}" }
p both { |v| v * 2 }
