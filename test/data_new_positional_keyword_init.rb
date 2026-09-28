D = Data.define(:x, :y) do
  def initialize(x:, y: 5) = super(x: x, y: y)
end
p D.new(1, 2)
p D.new(1)
p D.new(x: 3)
p D[4]

F = Data.define(:x, :y) do
  def initialize(x:, y: "none") = super(x: x.to_f, y: y)
end
p F.new(1, "s")
class G < F; end
p G.new(7).x

class X < Data.define(:a, :b)
  def initialize(a:, b: [])
    super(a: a, b: b)
  end
end
p X.new(1)
p X.new(1, [2])

H = Data.define(:a, :b) { def initialize(a:, **rest) = super(a: a * 2, **rest) }
p H.new(1, 2)
K = Data.define(:a, :b) { def initialize(a: 0, b: 1) = super }
p K.new(4)
p K.new
P = Data.define(:a, :b)
p P.new(1, 2)
