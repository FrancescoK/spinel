# A module included by a module is an ancestor of every class that includes
# the outer one: `module M2; include M1; end; class A; include M2; end` gives
# A the ancestors [A, M2, M1, ...], so A.include?(M1) and A.new.is_a?(M1)
# are true and M1 methods resolve. The membership tables held direct
# includes only, so both answered false (concerns include one another
# this way).
module M1; def a = 1; end
module M2; include M1; def b = 2; end
class A; include M2; end
p A.include?(M2), A.include?(M1), A.new.a, A.new.is_a?(M1), M2.include?(M1)
module M1; end
module M2; include M1; end
module M3; include M2; end
class A; include M3; include M1; end
class B < A; end
p A.ancestors.take(5), B.ancestors.take(6), M3.ancestors, B.include?(M1), M3.include?(M1), M1.include?(M2)
