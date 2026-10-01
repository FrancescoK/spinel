# A String handed to a thread or a fiber as its block's argument is the
# caller's String, as in CRuby: `Thread.new(s) { |t| t.upcase! }` and
# `Fiber.new { |x| x << "!" }.resume(f)` change s and f. The block's
# parameter took a box of a copy, and the change was lost.

s = +"ab"; Thread.new(s) { |t| t.upcase! }.join; p s
u = +"u"; Thread.new(u, 1) { |t, n| t << "x" * n }.join; p u
f = +"f"; Fiber.new { |x| x << "!" }.resume(f); p f
fb = Fiber.new { |x| x << "?"; Fiber.yield; x << "." }
g = +"g"; fb.resume(g); p g; fb.resume; p g
class K
  def initialize = (@s = +"i")
  def go = (Thread.new(@s) { |t| t << "x" }.join; @s)
end
p K.new.go
q = +"q"; [1].each { Thread.new(q) { |t| t << "z" }.join }; p q
r = +"r"; Thread.new(r) { |t| p t.size }.join; p r
