# An alias takes the method in effect where it appears: B.new.o calls M's
# hi in CRuby, even though B includes N, which defines hi too. Spinel's
# subclass would answer the alias through its own chain, N's hi, so the
# alias is refused, not answered wrongly.
module M; def hi = "M"; end
module N; def hi = "N"; end
class A
  include M
  alias_method :o, :hi
end
class B < A
  include N
end
p B.new.o
