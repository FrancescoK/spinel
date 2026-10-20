# `sort` and `reverse` on a yield, with an Array block at one call site and a
# Hash or String block at another. The yield used to take its first site's
# kind alone, and a Hash or String site beside an Array site failed to compile
# (an Array's IntArray in the String's slot, a PolyArray in the IntArray's).
# CRuby: [1, 2, 3], [[:a, 1]], "cba", [2, 1, 3].
def t_sort = yield.sort
def t_reverse = yield.reverse

p t_sort { [3, 1, 2] }
p t_sort { {a: 1} }
p t_reverse { "abc" }
p t_reverse { [3, 1, 2] }
