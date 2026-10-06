class Box
  attr_reader :v
  def v=(x)
    @v = x
  end
end
class R
  def initialize = (@b = Box.new)
  def run(n)
    @b.v = n + 1
    @b.v = n + 2
    @b.v = n + 3
    @b.v = n + 4
    @b.v = n + 5
    @b.v = n + 6
    @b.v = n + 7
    @b.v = n + 8
    yield @b.v
  end
end
r = R.new
t = 0
t += r.run(1) { |x| x * 2 }
t += r.run(2) { |x| x * 2 }
t += r.run(3) { |x| x * 2 }
t += r.run(4) { |x| x * 2 }
t += r.run(5) { |x| x * 2 }
t += r.run(6) { |x| x * 2 }
t += r.run(7) { |x| x * 2 }
t += r.run(8) { |x| x * 2 }
t += r.run(9) { |x| x * 2 }
t += r.run(10) { |x| x * 2 }
t += r.run(11) { |x| x * 2 }
t += r.run(12) { |x| x * 2 }
t += r.run(13) { |x| x * 2 }
t += r.run(14) { |x| x * 2 }
t += r.run(15) { |x| x * 2 }
t += r.run(16) { |x| x * 2 }
t += r.run(17) { |x| x * 2 }
t += r.run(18) { |x| x * 2 }
t += r.run(19) { |x| x * 2 }
t += r.run(20) { |x| x * 2 }
p t
