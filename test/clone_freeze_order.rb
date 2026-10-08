a = [1]
b = a.clone(freeze: (a = [2]; false))
p b, a

class Holder
  def initialize = (@v = [1])
  def go = @v.clone(freeze: (@v = [2]; false))
  def v = @v
end
h = Holder.new
p h.go, h.v

n = nil
p n&.clone(freeze: (raise "unexpected"))

y = [5]
c = y&.clone(freeze: (y = [6]; true))
p c, c.frozen?, y

f = false
x = [3]
d = x&.clone(freeze: f)
p d, d.frozen?

begin
  [1].clone(freeze: (s = 1; s))
rescue ArgumentError => e
  puts e.message
end
