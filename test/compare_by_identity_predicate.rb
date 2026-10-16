# Hash#compare_by_identity? reports false for an ordinary (value-keyed) hash.
# The mutating Hash#compare_by_identity is accepted only for object, Symbol,
# nil, true and false keys (hash_compare_by_identity.rb) and refused
# otherwise. This test pins the predicate's value-keyed answer.
def s(x); x; end
p s({}).compare_by_identity?
p s({ "a" => 1 }).compare_by_identity?
h = {}
p h.compare_by_identity?
# The receiver is evaluated before the answer, as CRuby evaluates it: the
# typed predicate folded to a bare false and dropped the call, side effect and
# all.
def g
  puts "g ran"
  { "b" => 2 }
end
p g.compare_by_identity?
