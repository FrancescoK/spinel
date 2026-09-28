class T < Struct.new(:a, :b); def initialize(...) = super(...); end
p T.new(1, 2)
p T.new("x", 2.5).b

E = Data.define(:a, :b) { def initialize(...) = super(...) }
p E.new(a: 1, b: 2)
p E.new(3, 4).b

S = Struct.new(:a, :b, keyword_init: true) do
  def initialize(...) = super(...)
end
p S.new(a: 1, b: 2)

W = Struct.new(:a, :b) do
  def initialize(...) = super(...)
end
p W.new(a: 1, b: "k")

class U < Struct.new(:a, :b, :c); def initialize(a, ...) = super(a * 10, ...); end
p U.new(1, 2, 3)

class V < Struct.new(:a, :b); def initialize(a, ...) = super(...); end
p V.new(1, 2)
