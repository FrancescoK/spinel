# Fiber.new(&blk) / Thread.new(&blk) with the method's own block parameter,
# named or anonymous: the fiber keeps the block and runs it later.
def mk(&b)
  Fiber.new(&b)
end
f = mk { |x| Fiber.yield(x * 2); :fin }
p f.resume(5), f.resume

def mk_used(&b)
  p b.call(1)
  Fiber.new(&b)
end
p mk_used { |x| x + 10 }.resume(5)

def mk_anon(&) = Fiber.new(&)
g = mk_anon { |x| x * 3 }
h = mk_anon { |x| x * 4 }
p g.resume(5), h.resume(5)

def th(&b) = Thread.new(&b)
p th { 42 }.value
def th_args(&b) = Thread.new(3, 4, &b)
p th_args { |x, y| x * y }.value
