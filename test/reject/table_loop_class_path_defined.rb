# `class M::One` defines One before the loop, and const_set replaces it
# (CRuby warns; M::One no longer has hi). A class definition in its place
# would reopen the old class, so the loop stays as written, which Spinel
# refuses.
module M; class Base; end; end
class M::One; def hi = "old"; end
module M
  T = { 1 => "One" }
  T.each { |c, n| const_set(n, Class.new(Base)) }
end
p M::One.new.respond_to?(:hi)
