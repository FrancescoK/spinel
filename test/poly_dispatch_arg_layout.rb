# A call on a value of more than one type binds its arguments in each
# class's arm by the same layout as a direct call (arg_layout, kw_plan):
# a splat anywhere among the positionals gathers them and the count is
# judged at run time before the keywords; a missing required keyword, a
# `**nil` callee given a key and an unknown String key raise CRuby's
# ArgumentError instead of dropping the arm into NoMethodError; a String
# or computed key is a keyword, not one more positional, run in source
# order; a literal keyword hash funds
# the required parameter after a leading optional. The class-side arms a
# class value reaches bind the same way.

def show
  p yield
rescue ArgumentError => e
  p [e.class, e.message]
end

class A1; def m(a, b = 7, c) = [:a, a, b, c]; end
class B1; def m(a, b = 8, c) = [:b, a, b, c]; end
x = [1]
y = [1, 2, 3]
[A1.new, B1.new].each do |o|
  show { o.m(*x, 2) }
  show { o.m(0, *y) }
  show { o.m(*x, *y) }
  show { o.m(*[], 5) }
  show { o.m(*x, 2, *x) }
end

class A2; def n(a, *r, z) = [:a, a, r, z]; end
class B2; def n(a, *r, z) = [:b, a, r, z]; end
[A2.new, B2.new].each do |o|
  show { o.n(*x, 5, 6) }
  show { o.n(*[], 5) }
  show { o.n(4, *y, 5) }
end

class A3; def q(a, k: 1) = [:a, a, k]; end
class B3; def q(a, k: 2) = [:b, a, k]; end
[A3.new, B3.new].each do |o|
  show { o.q(*x, k: 3) }
  show { o.q(*[], k: 3) }
  show { o.q(*y, k: 3) }
  show { o.q(1, "s" => 2) }
  show { o.q(1, k: 5, "s" => 2) }
end

class A4; def r(a, k1:) = [:a, a, k1]; end
class B4; def r(a, k1:) = [:b, a, k1]; end
[A4.new, B4.new].each do |o|
  show { o.r(1) }
  show { o.r(*x) }
  show { o.r(*[]) }
  show { o.r(*x, k1: 2) }
end

class A5; def k(k1:) = k1; end
class B5; def k(k1:) = [:b, k1]; end
[A5.new, B5.new].each { |o| show { o.k } }

class A6; def h(a, b = {}) = [:a, a, b]; end
class B6; def h(a, b = {}) = [:b, a, b]; end
[A6.new, B6.new].each do |o|
  show { o.h(1, "s" => 2, t: 3) }
  show { o.h(*x, "s" => 2) }
end

class A7; def s(*v) = [:a, v]; end
class B7; def s(*v) = [:b, v]; end
[A7.new, B7.new].each { |o| show { o.s(1, "s" => 2) } }

class A8; def g(a, **nil) = [:a, a]; end
class B8; def g(a, **nil) = [:b, a]; end
[A8.new, B8.new].each { |o| show { o.g(1, "s" => 2) } }

class A9; def f(a = 5, c) = [:a, a, c]; end
class B9; def f(a = 6, c) = [:b, a, c]; end
[A9.new, B9.new].each do |o|
  show { o.f(k: 1) }
  show { o.f(1, k: 1) }
end

class C1; def self.c(a, b = a) = [:c, a, b]; end
class D1; def c(a, b = a) = [:d, a, b]; end
[C1, D1.new].each do |o|
  show { o.c(1) }
  show { o.c(*y) }
  show { o.c(*x, 2) }
  show { o.c }
end

$log = []
def tr(x) = ($log << x; x)
class A10; def m(key: 0, **k) = [:a, key, k]; end
class B10; def m(key: 0, **k) = [:b, key, k]; end
[A10.new, B10.new].each do |o|
  show { o.m(tr(:key) => 4) }
  show { o.m(tr(:zz) => tr(5), key: tr(6)) }
end
p $log
[A3.new, B3.new].each { |o| show { o.q(1, tr(:z) => 2) } }
[A6.new, B6.new].each { |o| show { o.h(1, tr(:z) => 2, "s" => 3) } }
