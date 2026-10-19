# A Hash made to compare by identity is no Set's compare_by_identity: the
# program's Sets of Strings, Integers and Floats are not refused for it.
require "set"

h = {}.compare_by_identity
k = :a
h[k] = 1
p h[k], h.compare_by_identity?
words = Set["a", "b"]
words << "c"
p words.include?("b"), words.size
p Set[1, 2.5].include?(2.5)
