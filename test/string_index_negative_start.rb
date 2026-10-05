# String#index with a negative start before the string answers nil, as
# CRuby does; it was clamped to 0 and found the first match.
s = "a.b.c.d"
p s.index(".", -100), s.index(".", -7), s.index(".", -8), s.rindex(".", -100), "abc".index("", -3), "abc".index("", -4), "aé.b".index(".", -100)
t = [s, 1].first
p t.index(".", -100)
