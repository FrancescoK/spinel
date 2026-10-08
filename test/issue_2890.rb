# spinel: gc-minor
C = Data.define(:a)
r = [C.new(1), C.new(2)]
p r.map { |c| c.with(a: c.a + 1) }.map(&:a)

D = Data.define(:a, :b)
ds = [D.new(1, "x"), D.new(2, "y")]
p ds.map { |d| d.with(a: d.a * 10) }.map(&:a)
p ds.map { |d| d.with(b: d.b.upcase).to_h }
