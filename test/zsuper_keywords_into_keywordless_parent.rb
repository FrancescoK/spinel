# A bare `super` passes the method's keywords as keywords, and a parent
# that takes no keyword at all -- no keyword parameter, no `**kwrest` --
# takes them as one more positional Hash, the method's `**` first and then
# its named keywords, none when they are empty: counted, a parent without
# room raises `wrong number of arguments`, and one with an optional or a
# rest binds the Hash there. They were dropped, so `def n(kx: 90) = super`
# into `def n()` answered where CRuby raises. Through a class parent and an
# included module.
def t
  p yield
rescue ArgumentError => e
  p e.message
end
module M1; def m() = []; end
class C1; include M1; def m(kx: 90) = super; end
t { C1.new.m }
class P2; def m(a = {}) = [a]; end
class Q2 < P2; def m(kx: 90) = super; end
t { Q2.new.m }
t { Q2.new.m(kx: 1) }
class P3; def m(*r) = r; end
class Q3 < P3; def m(x, k: 1, **o) = super; end
t { Q3.new.m(5) }
t { Q3.new.m(5, z: 2) }
class P4; def m(a) = [a]; end
class Q4 < P4; def m(**o) = super; end
t { Q4.new.m }
t { Q4.new.m(z: 1) }
class P5; def m(a = 1, b) = [a, b]; end
class Q5 < P5; def m(k: 3) = super; end
t { Q5.new.m }
class P6; def m() = :none; end
class Q6 < P6; def m(**o) = super; end
t { Q6.new.m }
t { Q6.new.m(z: 1) }
class P7; def m(a, k: 0) = [a, k]; end
class Q7 < P7; def m(a, k: 5) = super; end
t { Q7.new.m(1) }
