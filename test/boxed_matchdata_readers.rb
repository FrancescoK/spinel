# A MatchData read out of a Hash or a mixed Array answers its readers, as a
# typed one does: pre_match, post_match and captures had raised
# NoMethodError, and size, to_a, [] and values_at answered 0, nils or
# raised.
h = {m: "xAB!".match(/a(?<b>b)(?<c>z)?/i), n: 1}
m = h[:m]
p m.pre_match
p m.post_match
p m.captures
p m.size
p m.length
p m.to_a
p m[0]
p m[1]
p m[-1]
p m[:b]
p m["b"]
p m[:c]
p m.values_at(0, 1)
p m.values_at(:b, -1)
xs = ["zz".match(/z/), 2]
p xs[0].pre_match
p xs[0].size
p({a: 1, b: 2}.values_at(:a))
p [[1, 2], 3][0].values_at(1)
p [{k: 9}, 1][0][:k]
p [[5, 6], 1][0][1]
begin
  [1, 2][0].pre_match
rescue NoMethodError => e
  p e.message
end
