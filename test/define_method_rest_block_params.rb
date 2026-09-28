# define_method and define_singleton_method take rest, post and block
# parameters (and a singleton method keywords) as a method does
class P
  define_method(:r) { |a, *rest| [a, rest] }
  define_method(:post) { |a, *m, z| [a, m, z] }
  define_method(:bl) { |a, &b| b.call(a) }
  define_method(:bl2) { |a, &b| b ? b.call(a) : :none }
  private define_method(:pk) { |a, k: 1| a + k }
  def via = pk(1, k: 2)
end
o = P.new
p o.r(1), o.r(1, 2, 3), o.post(1, 2), o.post(1, 2, 3, 4)
p o.bl(2) { |x| x * 5 }, o.bl2(3), o.bl2(3) { |x| -x }
p o.via
begin; o.pk(1); rescue NoMethodError => e; p e.class; end
begin; o.r; rescue ArgumentError => e; p e.message; end
begin; o.post(1); rescue ArgumentError => e; p e.message; end
class Sc
  define_singleton_method(:kk) { |a, k: 1| a + k }
  define_singleton_method(:sr) { |a, *r| [a, r] }
end
p Sc.kk(1), Sc.kk(1, k: 5), Sc.sr(1, 2)
class Cap
  x = 5
  define_method(:cr) { |*a| a + [x] }
end
p Cap.new.cr(1, 2)
