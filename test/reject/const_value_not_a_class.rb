# CRuby refuses to LOAD this: "A is not a class (TypeError)". spinel built it,
# and resolved the name TWO ways in one file -- `p A` read the constant while
# `A.hi` read the class (#4318).
# spinel: reject-constant-kind
A = 1

class A
  def self.hi = "hi"
end

p A.hi
