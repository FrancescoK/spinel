# A constant named by its path widens from what is pushed into it, as the
# bare name's does: `H::L << 64` makes L an Array of mixed values.
module H
  L = ["a"]
  T = { "k" => 1 }
end
H::L << 64
p H::L
H::T[:s] = "v"
p H::T
module H
  def self.add = L << 2.5
end
H.add
p H::L, H::L.size
