# An alias takes the method in effect where it appears: B.new.o calls M's
# hi in CRuby, even though B includes N, which defines hi too. The alias
# names a copy of A's hi under a shadow name, which B's chain does not
# answer with N's (it was refused before).
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
