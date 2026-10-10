# A String Range argument is rooted until the callee holds it: a generated
# constructor roots a String Range parameter before it allocates the
# object, and a Range made in an argument list is held in a rooted temp
# while a later argument allocates. A Range literal's own roots end with
# the expression that made it, so endpoints made on the spot were swept and
# the object kept freed strings. Struct (positional, [], keyword_init, a
# custom initialize with a keyword), Data (positional, keyword, #with), a
# class's initialize and an exception's, each with a later argument that
# allocates (an interpolated String or Symbol).
# spinel: gc-stress
S = Struct.new(:rng)
S2 = Struct.new(:rng, :tag)
K = Struct.new(:rng, :n, keyword_init: true)
D = Data.define(:rng, :n)
DS = Data.define(:rng, :tag)
C = Struct.new(:rng, :t) do
  def initialize(r, t:)
    super(r, t)
  end
end
class Plain
  def initialize(r, tag:)
    @r = r
    @tag = tag
  end
  attr_reader :r, :tag
end
class Tagged < StandardError
  def initialize(r, tag:)
    @r = r
    super(tag)
  end
  attr_reader :r
end
n = 300
a1 = (1..n).map { |i| S.new(i.to_s..(i + 3).to_s) }
a2 = (1..n).map { |i| S[i.to_s..(i + 2).to_s] }
a3 = (1..n).map { |i| S2.new(i.to_s..(i + 3).to_s, :"t#{i}") }
a4 = (1..n).map { |i| S2.new(i.to_s..(i + 4).to_s, "s#{i}") }
a5 = (1..n).map { |i| K.new(rng: i.to_s..(i + 3).to_s, n: "k#{i}") }
a6 = (1..n).map { |i| D.new(i.to_s..(i + 3).to_s, i) }
a7 = (1..n).map { |i| DS.new(rng: i.to_s..(i + 3).to_s, tag: :"d#{i}") }
d0 = D.new("a".."b", 0)
a8 = (1..n).map { |i| d0.with(rng: i.to_s..(i + 5).to_s) }
a9 = (1..n).map { |i| C.new(i.to_s..(i + 3).to_s, t: "c#{i}") }
a10 = (1..n).map { |i| Plain.new(i.to_s..(i + 3).to_s, tag: "x#{i}") }
a11 = (1..n).map { |i| Tagged.new(i.to_s..(i + 3).to_s, tag: "e#{i}") }
GC.start
p a1.last.rng, a2.last.rng, a3.last.rng, a3.last.tag, a4.last.rng, a5.last.rng, a5.last.n
p a6.last.rng, a7.last.rng, a7.last.tag, a8.last.rng, a9.last.rng, a9.last.t
p a10.last.r, a10.last.tag, a11.last.r, a11.last.message
p [a1, a2, a3, a4, a5, a6, a7, a8, a9].map { |a| a.sum { |o| o.rng.to_a.size } }
p a10.sum { |o| o.r.to_a.size }, a11.sum { |o| o.r.to_a.size }
