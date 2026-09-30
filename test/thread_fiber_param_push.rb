# A Thread.new or Fiber.new block's parameter that the body only pushes into
# or writes an element of holds whatever the thread's arguments or the
# resume value are: the body declares it boxed. The push read as evidence
# typed it a typed array ("t is a String array" for `t << "x"`), and the
# body pushed into the boxed value as that array: the C did not compile, for
# a String argument and for an Integer array alike.

s = +"ab"
p Thread.new(s) { |t| t << "x" * 3 }.value
p Thread.new(+"cd") { |t| t.concat("y", "z") }.value
a = [1]
Thread.new(a) { |t| t << 2 }.join
p a
Thread.new(a, 5) { |t, n| t.push(n); t[4] = 9 }.join
p a
h = {a: 1}
Thread.new(h) { |t| t[:k] = 2 }.join
p h
p Thread.new(+"ef", "!") { |t, e| t << e }.value

f = Fiber.new { |t| t << "y"; t.concat("z") }
p f.resume(+"q")
g = Fiber.new { |t| t[0] = "Q"; Fiber.yield t.size; t << "R" }
w = ["w", "v"]
p g.resume(w)
g.resume
p w
n = Fiber.new { |t| t.push(t.size * 10) }
p n.resume([7, 8])
p Enumerator.new { |y| y << 1 << 2 }.to_a
