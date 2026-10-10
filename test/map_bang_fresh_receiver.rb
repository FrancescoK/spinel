# map! over an Array nothing else holds (a literal, or the fresh result of
# split/scan/map) whose block answers another kind than its elements: the
# loop stored the block's values back into the typed receiver
# (`sp_StrArray_set(a, i, <an Integer>)`) and the C did not build. RubyGems'
# Version#partition_segments is this shape.
p "1 2".split(" ").map! { |s| s.to_i }
p ["1", "a"].map! { |s| s == "1" ? s.to_i : s }
p "1.2.a".scan(/\d+|[a-z]+/i).map! { |s| /\A\d/.match?(s) ? s.to_i : -s }.freeze
p [1, 2].map { |x| x * 2 }.collect! { |x| x.to_s }
def segs(v) = v.scan(/\d+/).map! { |s| s.to_i }
p segs("3.14")
p "a b".split(" ").map! { |s| s.upcase }
