# A MatchData read out of a container answers string, its subject, as a
# typed one does (NoMethodError before).
m = {m: "xAB!".match(/a(b)/i), n: 1}[:m]
p m.string
p m.string.frozen?
p m.string.length
xs = ["hello".match(/l+/), 0]
p xs[0].string
p xs[0].pre_match + xs[0][0] + xs[0].post_match == xs[0].string
