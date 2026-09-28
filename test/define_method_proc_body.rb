# define_method takes its body from a Proc argument as well as a block:
# a lambda or proc literal, a local holding one, or `&` of either.
class P
  define_method(:f, lambda { |a| a + 1 })
  define_method(:g, proc { |a| a * 2 })
  pr = ->(a) { a - 1 }
  define_method(:h, pr)
  pr2 = proc { |a, b| "#{a}-#{b}" }
  define_method(:i, &pr2)
  define_method(:j, &->(a) { a * 3 })
  define_method(:n, Proc.new { |a| a * 5 })
  define_method("s", proc { |x = 5| x })
  k = 7
  define_method(:k, -> { k + @v })
  define_method(:kw, ->(a, b: 2) { a * b })
  define_singleton_method(:cm, lambda { |a| a + 100 })
  private define_method(:priv, -> { 1 })
  def pub = priv + 1
  def initialize; @v = 3; end
end

o = P.new
p o.f(1), o.g(2), o.h(3), o.i(1, 2), o.j(2), o.n(2)
p o.s, o.s(9), o.k, o.kw(3), o.kw(3, b: 4), P.cm(1), o.pub
begin; o.priv; rescue NoMethodError => e; p e.class; end

# the method keeps lambda arity rules whatever the Proc was
begin; o.f(1, 2); rescue ArgumentError => e; p e.message; end
begin; o.g(1, 2); rescue ArgumentError => e; p e.message; end
begin; o.i(1); rescue ArgumentError => e; p e.message; end
begin; o.k(1); rescue ArgumentError => e; p e.message; end

# the local is still the Proc it was, and shares its captures with the method
class Q
  pr = ->(a) { a + 1 }
  define_method(:q, pr)
  p pr.call(1), pr.lambda?
  n = 0
  inc = proc { n += 1 }
  define_method(:inc, &inc)
  inc.call
  define_method(:n) { n }
end
q = Q.new
p q.q(1)
q.inc
q.inc
p q.n
