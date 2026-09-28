hs = {1 => [1]}
hs[1] |= [7]
p hs
hs[1] &= [7, 8]
p hs
hs[1] += [9]
p hs
hs[1] -= [9]
p hs
hs[1] *= 2
p hs
p(hs[1] |= [2])
h2 = {1 => [1], 2 => "a"}
h2[1] |= [3]
h2[1] &= [3]
h2[2] += "b"
h2[2] *= 2
p h2
h3 = {:a => 1, :b => 2.5, :c => [1]}
h3[:a] |= 6
h3[:a] &= 3
h3[:a] ^= 7
h3[:a] <<= 2
h3[:a] >>= 1
h3[:b] += 1
h3[:c] |= [2]
p h3
g = Hash.new
g[:x] ||= []
g[:x] |= [1]
g[:x] |= [1, 2]
g[:y] = 3
p g
class C
  def initialize; @h = {1 => [1], 2 => 5}; end
  def run; @h[1] |= [4]; @h[2] |= 2; @h[1] -= [1]; p @h; p(@h[1] |= [9]); end
end
C.new.run
h = {1 => [1], 2 => 3}
h[1] <<= 5
h[2] <<= 2
h[2] >>= 1
p h
h[1] << 6
p h
nest = {a: {b: [1]}}
nest[:a][:b] |= [2]
p nest
arr = [[1], "s", 2]
arr[0] |= [4]
p arr
$g = {k: [1], j: 1}
$g[:k] |= [2]
p $g
