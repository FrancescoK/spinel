# `super(*args)` / `super(**kw)` in a Struct or Data initialize spreads the
# arguments across the members at run time.

H = Data.define(:song) { def initialize(**kw) = super(**kw) }
p H.new(song: 3).song

class T < Struct.new(:a, :b)
  def initialize(*args) = super(*args)
end
t = T.new(1, 2)
p t.b
p t.a + t.b
p T.new(1).b
begin
  T.new(1, 2, 3)
rescue ArgumentError => e
  p e.message
end

K = Struct.new(:a, :b, keyword_init: true) do
  def initialize(**kw) = super(**kw)
end
k = K.new(a: 1, b: 2)
p [k.a, k.b]
p K.new(b: 7).to_a

D = Data.define(:x, :y) do
  def initialize(**kw) = super(**kw, y: 9)
end
p D.new(x: 1)

class S < Struct.new(:a, :b)
  def initialize(*args, **kw) = super(*args, **kw)
end
p S.new(1, 2).to_a
p S.new(a: 3, b: 4).to_a

D2 = Data.define(:x, :y) do
  def initialize(**kw) = super(**kw.transform_values { _1 * 2 })
end
p D2.new(x: 1, y: 2)

class W < Struct.new(:a, :b)
  def initialize(*args) = super(*args.map { _1 * 10 })
end
p W.new(1, 2).b

class S2 < Struct.new(:a, :b, :c)
  def initialize(*args) = super(0, *args)
end
p S2.new(1, 2).to_a

class S3 < Struct.new(:a, :b)
  def initialize(**kw) = super(**kw)
end
p S3.new(a: 1, b: "x")

class S4 < Struct.new(:a, :b)
  def initialize(*) = super(*)
end
p S4.new(5, 6).to_a

class S5 < Struct.new(:a, :b, keyword_init: true)
  def initialize(**) = super(**)
end
p S5.new(a: 5, b: 6).to_a

D3 = Data.define(:x, :y) do
  def initialize(**kw) = super(**kw)
end
p D3.new(x: 1, y: 2)
begin
  D3.new(x: 1)
rescue ArgumentError => e
  p e.message
end

D4 = Data.define(:x, :y) do
  def initialize(x:, **rest) = super(x: x * 3, **rest)
end
p D4.new(x: 1, y: "s")
