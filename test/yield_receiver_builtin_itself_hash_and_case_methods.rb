# itself on a Hash site beside several other kinds, and capitalize/
# downcase/upcase/swapcase on a String site beside a Symbol one -- the
# rest of kilau's K-033 (K-029/K-030's "other names likely follow the same
# pattern" leftover).
#
# itself had no Hash row at all, so a Hash site next to e.g. an Integer
# one was never answered by the per-yield-site table; without every site
# answered, the whole method stayed unwidened and later sites' pointer
# values got forced into the first site's own (here, scalar) C
# representation -- a compile failure, not a silently wrong value.
#
# capitalize/downcase/upcase/swapcase had no String-or-Symbol gating at
# all (only arrays/Hash/numerics were ever considered here), so neither
# site was ever answered, and the SECOND site's value got forced through
# the FIRST site's own representation -- here String's and Symbol's C
# representations happen to coexist in the same narrow slot without the
# compiler noticing the clash, so it compiled but answered a silently
# wrong value (a stray `nil` instead of the Symbol CRuby expects).
def t_itself = yield.itself
p t_itself { 7 }
p t_itself { 2.5 }
p t_itself { "abc" }
p t_itself { :ab }
p t_itself { [3, 1, 2] }
p t_itself { { a: 1 } }

def t_capitalize = yield.capitalize
p t_capitalize { "abc" }
p t_capitalize { :ab }

def t_downcase = yield.downcase
p t_downcase { "ABC" }
p t_downcase { :AB }

def t_upcase = yield.upcase
p t_upcase { "abc" }
p t_upcase { :ab }

def t_swapcase = yield.swapcase
p t_swapcase { "AbC" }
p t_swapcase { :aB }
