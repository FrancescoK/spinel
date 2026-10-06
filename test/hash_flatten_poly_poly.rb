# Hash#flatten on a Hash of mixed keys (sp_PolyPolyHash). The table's order
# lists slots, and the interleave handed a slot index to
# sp_PolyPolyHash_get as a key, so the generated C did not build, with or
# without a block; a boxed receiver given a block reaches that arm through
# its Hash face.

def t(k)
  p({1 => 2, "a" => :b}.flatten)
  p({1 => [2, [3]], :s => nil}.flatten(2))
  h = k == 0 ? {1 => 2, 3 => [4]} : nil
  p h.flatten { |*b| break :cut }
  p h.flatten(2) { |*b| 1 }
  bx = [{"x" => [1]}, 7][k]
  p bx.flatten { |*b| break :cut }
end

t(ARGV.size)
