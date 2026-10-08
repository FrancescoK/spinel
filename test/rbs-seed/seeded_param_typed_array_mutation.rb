# The seed must not bypass the existing refusal when a converted copy
# would lose a mutation of an array the caller still holds (#4480, #6514).
# spinel: rbs-seed-check
Box = Struct.new(:a)
module SeedArrayMutation
  def self.add(out)
    out << "z"
  end
end
src = [1, 2]
x = Box.new(src).a
SeedArrayMutation.add(x)
p src, x
