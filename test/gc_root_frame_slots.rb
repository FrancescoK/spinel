# A generated function keeps its boxed temporaries in one root frame whose
# slots are shared between disjoint blocks and rewritten on every loop
# iteration. Each shape below allocates between the point a temporary is
# made and the point it is read, so a slot that went unregistered, was
# zeroed too late or was shared with a live neighbour would read a freed
# object. Run under SPINEL_GC_STRESS=1 by gc-minor-test.
# spinel: gc-stress
# spinel: gc-minor
def pick(i)
  case i % 5
  when 0 then "s#{i}" * 4
  when 1 then [i, "a#{i}"]
  when 2 then { i => "h#{i}" }
  when 3 then i * 1.5
  else nil
  end
end

def churn(n)
  Array.new(n * 3) { |k| "x" * (k % 17 + 1) }.size
end

def combine(a, b, c)
  [a, b, c].inspect.size
end

# boxed call arguments (each a temporary in the frame) across sibling
# blocks and inside loops
def shapes(n)
  out = []
  n.times do |i|
    a = pick(i)
    b = pick(i + 1)
    out << combine(pick(i), pick(i + 1), pick(i + 2))
    y = a.is_a?(Array) ? a.size : (a.is_a?(String) ? a + b.inspect : a.inspect)
    out << combine(y, pick(i + 3), [a, y])
    if i.even?
      t = [a, b].inspect
      churn(2)
      out << t.size
    else
      u = { "k" => a, "v" => b }.inspect
      churn(3)
      out << u.size
    end
    j = 0
    while j < 3
      c = pick(i + j)
      churn(1)
      out << (c.nil? ? 0 : c.inspect.size)
      out << combine(pick(j), c, pick(i + j + 1)) if j.odd?
      j += 1
    end
  end
  out
end

# temporaries live across an unwinding exception and a fiber switch
def unwind(i)
  v = pick(i)
  begin
    w = pick(i + 2)
    raise ArgumentError, [v, w].inspect if i % 3 == 0
    churn(2)
    [v, w].inspect.size
  rescue ArgumentError => e
    churn(2)
    e.message.size
  end
end

def deep(n, acc)
  return acc.size if n == 0
  x = pick(n)
  y = pick(n + 3)
  acc << [x, y].inspect
  churn(1)
  deep(n - 1, acc)
end

r1 = shapes(12)
r2 = (0...9).map { |i| unwind(i) }
f = Fiber.new do
  s = 0
  4.times do |i|
    p1 = pick(i)
    p2 = Fiber.yield(p1.inspect.size)
    churn(2)
    s += [p1, p2].inspect.size
  end
  s
end
r3 = []
v = f.resume
4.times { |i| r3 << v; v = f.resume(pick(i + 7)) }
r3 << v
puts r1.inspect
puts r2.inspect
puts r3.inspect
puts deep(40, [])
