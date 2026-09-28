# A `**` forwarded to a method on a receiver of more than one class binds by
# name in every arm: an anonymous `**`, an empty or literal `**{...}`, mixed
# with literal keys, into keyword params, a **kwrest, or optional positionals.

class Pa; def run(t, k: 1) = k; end
class Pb; def run(t, k: 1) = k + 1; end
def disp(o, t, **) = o.run(t, **)
p disp(ARGV.empty? ? Pa.new : Pb.new, 0)
p disp(ARGV.empty? ? Pb.new : Pa.new, 0, k: 10)
p [Pa.new, Pb.new].map { |o| o.run(0, **{}) }
p [Pa.new, Pb.new].map { |o| o.run(0, **{k: 3}) }

class Qa; def m(a, k: 1, j: 2) = a + k + j; end
class Qb; def m(a, k: 1, j: 2) = a * k * j; end
qs = [Qa.new, Qb.new]
h = {j: 4}
qs.each { |o| p o.m(2, k: 7, **h) }
qs.each { |o| p o.m(2, j: 10, **{k: 3}) }
def an(o, **) = o.m(1, **)
qs.each { |o| p an(o, k: 2) }
qs.each { |o| p an(o) }
def lit_then_fwd(o, **) = o.m(5, k: 0, **)
qs.each { |o| p lit_then_fwd(o, k: 7) }
qs.each do |o|
  begin
    an(o, zz: 1)
  rescue ArgumentError => e
    p e.message
  end
end

class Ra; def m(a, **kw) = [a, kw]; end
class Rb; def m(a, **kw) = [a * 2, kw]; end
rs = [Ra.new, Rb.new]
rs.each { |o| p o.m(1, **{}) }
def ank(o, **) = o.m(1, **)
rs.each { |o| p ank(o, y: 2) }

class Sa; def m(a, b = 5, k: 1) = a + b + k; end
class Sb; def m(a, b = 6, k: 2) = a * b * k; end
ss = [Sa.new, Sb.new]
ss.each { |o| p o.m(1, **{}) }
def ans(o, *a, **) = o.m(*a, **)
ss.each { |o| p ans(o, 1, 2, k: 3) }

class Ta; def m(a, k:) = a + k; end
class Tb; def m(a, k:) = a - k; end
[Ta.new, Tb.new].each do |o|
  begin
    o.m(1, **{})
  rescue ArgumentError => e
    p e.message
  end
end
