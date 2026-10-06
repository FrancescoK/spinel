# Hash#merge and merge! given several hashes and a conflict block that
# breaks: the break leaves the whole call, whichever hash's conflict runs
# the block, and merge! keeps what the hashes before it merged. The call is
# folded into one merge per hash, and each inner step took the break for
# its own: its boxed answer went into the next step's Hash slot, and the C
# did not build.
def run(k)
  r = {"a" => 1, "b" => 2}
  a0 = {"a" => 2}
  a1 = {"b" => 5}
  a2 = {"c" => 7}
  p r.merge(a0, a1) { |key, o, n| break :first if key == "a"; o + n }
  p r.merge(a0, a1, a2) { |key, o, n| break [key, o, n] if key == "b"; o + n }
  p r.merge(a0, a1, a2) { |key, o, n| break :never if k > 9; o * n }
  h = {"a" => 1, "b" => 2}
  p h.merge!(a0, a1) { |key, o, n| break :stop if key == "b"; o * n }
  p h
  g = {"a" => 1, "b" => 2}
  p g.merge!(a2, a1, a0) { |key, o, n| break :done if key == "a"; o - n }
  p g
  log = []
  w = r.merge(a0, a1) { |key, o, n| log << [key, o, n]; break :cut if log.size > 3; o }
  p w, log
  p r
end
run(ARGV.size)
