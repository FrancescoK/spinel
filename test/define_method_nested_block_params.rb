# A define_method nested in a body statement (a `begin`, an `if`, an
# iterator's block), in a method's body or at the top level takes its rest,
# post, keyword-rest and `&block` parameters as one written as the body's
# own statement does: the block a call gives reaches `&b`, and the extra
# arguments reach the rest
class Nest
  begin
    define_method(:bg) { |x, &b| b ? b.call(x) : :noblock }
  end
  if true
    define_method(:cnd) { |&b| b.call(7) }
  end
  [1].each do |k|
    define_method(:it) { |x, *r, &b| [x, r, k, (b ? b.call : nil)] }
  end
  begin
    define_method(:po) { |a, *m, z| [a, m, z] }
    define_method(:kr) { |a, **kw| [a, kw] }
    define_singleton_method(:cs) { |*r, &b| [r, b.call] }
  end
  def self.install
    define_method(:late) { |*a, &b| [a, b ? b.call : :none] }
  end
  install
  def via = bg(4) { |v| v * 10 }
  def via_self = self.cnd { |v| v + 1 }
end
o = Nest.new
p o.bg(1) { |v| v + 1 }, o.bg(1)
blk = proc { |v| v * 3 }
p o.bg(2, &blk), o&.bg(3) { |v| -v }
p o.cnd { |v| v * 2 }, o.via, o.via_self
p o.it(1), o.it(1, 2, 3) { :b }
p o.po(1, 2), o.po(1, 2, 3, 4), o.kr(1), o.kr(1, a: 2)
p Nest.cs(1, 2) { 3 }
p o.late(1, 2) { 5 }, o.late
begin; o.po(1); rescue ArgumentError => e; p e.message; end
define_method(:top) { |*a, &b| [a, b&.call] }
p top(1, 2) { 3 }, top
