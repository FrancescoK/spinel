# A Struct made in place is kept alive while its values are gathered.
# to_a, values, deconstruct, values_at and deconstruct_keys build an Array or
# a Hash from the members. The Struct they read was held by nothing while
# that container was allocated, which SPINEL_GC_STRESS=2 shows.
# spinel: gc-stress
Pt = Struct.new(:a, :b)
Dt = Data.define(:a, :b)

def rest(*r) = r
def make(n) = Pt.new("a#{n}", "b#{n}")

p Pt.new("a" + "1", "b" + "2").to_a
p Pt.new("a" + "1", "b" + "2").values
p Pt.new("a" + "1", "b" + "2").deconstruct
p make(3).to_a
p Pt.new([1], [2]).to_a
p Pt.new(1, "b" + "2").to_a.join

# a splat converts through to_a
p [*Pt.new(1, 2)]
p [0, *Pt.new("a" + "1", "b" + "2")]
p rest(*Pt.new("a" + "1", "b" + "2"))
x, y = *Pt.new("a" + "1", "b" + "2")
p [x, y]

# values_at, by literal keys and by keys known only at run time
i = 1
p Pt.new("a" + "1", "b" + "2").values_at(0, 1)
p Pt.new("a" + "1", "b" + "2").values_at(0..1)
p Pt.new("a" + "1", "b" + "2").values_at(i, 0)

# deconstruct_keys answers a Hash
p Pt.new("a" + "1", "b" + "2").deconstruct_keys([:a, :b]).to_a
p Pt.new("a" + "1", "b" + "2").deconstruct_keys(nil).to_a

# Data has deconstruct and deconstruct_keys
p Dt.new(a: "a" + "1", b: "b" + "2").deconstruct
p Dt.new(a: "a" + "1", b: "b" + "2").deconstruct_keys([:a]).to_a
p Dt.new(a: "a" + "1", b: "b" + "2").with(a: "c" + "3").deconstruct

# a run-time key may drop the variable the receiver was read from, and a
# later key allocates: the temporary is then the Struct's only holder
def spare(n) = ["s#{n}", "t#{n}"].size - 2 + n
def dropped
  l = make(4)
  l.values_at((l = nil; spare(0)), spare(1), spare(0))
end
p dropped
