# Literal half-open Float ranges -- (1.5..), (..2.5), (1.5..nil),
# (nil..2.5) -- are Float ranges, as CRuby's are. They were Integer ranges
# with the Float bound truncated: (1.5..) inspected as
# "1..9223372036854775807" and (..2.5).include?(2.2) answered false. Their
# bsearch bisects the doubles in CRuby's order (an infinite bound is a bound
# like any other), and step walks an endless one until a break. An open
# Integer range's #count is Infinity, and a beginless one's #size the
# TypeError, as CRuby 4.0 answers.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue StandardError => e
  puts "#{s}: #{e.class}: #{e.message}"
end
e = (1.5..)
b = (..2.5)
n = (1.5..nil)
m = (nil..2.5)
xr = (...2.5)
t("e") { e }
t("b") { b }
t("n") { n }
t("m") { m }
t("x") { xr }
t("e include") { e.include?(100.0) }
t("b include") { b.include?(2.2) }
t("x include") { xr.include?(2.5) }
t("e cover") { e.cover?(1.0) }
t("b ===") { b === -1e300 }
t("e begin") { e.begin }
t("e end") { e.end }
t("b begin") { b.begin }
t("b end") { b.end }
t("e first") { e.first }
t("b first") { b.first }
t("e min") { e.min }
t("b max") { b.max }
t("x max") { xr.max }
t("e max") { e.max }
t("b min") { b.min }
t("e last") { e.last }
t("e each") { e.each { |i| } ; nil }
t("b each") { b.each { |i| } ; nil }
t("e to_a") { e.to_a }
t("b to_a") { b.to_a }
t("e size") { e.size }
t("b size") { b.size }
t("e count") { e.count }
t("b count") { b.count }
t("e sum") { e.sum }
t("e ==") { e == (1.5..nil) }
t("e eql") { e.eql?(1.5..) }
t("e hash eq") { e.hash == (1.5..).hash }
t("e exclude_end") { e.exclude_end? }
t("x exclude_end") { xr.exclude_end? }
t("e to_s") { e.to_s }
t("b to_s") { b.to_s }
t("e minmax") { e.minmax }
t("clamp") { 9.0.clamp(e) }
t("clamp b") { 9.0.clamp(b) }
t("e step") { y = []; e.step(0.5) { |v| y << v; break if y.size > 2 }; y }
t("e bsearch") { e.bsearch { |v| v >= 10 } }
t("b bsearch") { b.bsearch { |v| v >= 1 } }
t("ib size") { (..3).size }
t("ib count") { (..3).count }
t("ie size") { (1..).size }
t("ie count") { (1..).count }
t("ib count blk") { (..3).count { |i| i > 0 } rescue $!.class }
t("i size") { (1..3).size }
t("i count") { (1...3).count }

r = (1.0..3.0)
t("var bsearch") { r.bsearch { |v| v * v >= 2.0 } }
t("var any") { r.bsearch { |v| 2.5 <=> v } }

# bsearch
inf = Float::INFINITY
p((..-0.1).bsearch { |x| x > 0.0 })
p((...-0.1).bsearch { |x| x > 0.0 })
p((..-0.1).bsearch { |x| nil })
p((..10.0).bsearch { |x| x >= 2 })
p((..10.0).bsearch { |x| x >= 1.5 })
p((...inf).bsearch { |x| true })
p((..-inf).bsearch { |x| true })
p((...-inf).bsearch { |x| true })
p((..5.0).bsearch { |x| -1 })
p((..1.1).bsearch { |x| 1 })
p((..6.3).bsearch { |x| x < 2 ? 1 : -1 })
p((..5.0).bsearch { |x| Float::INFINITY })
p((..8.0).bsearch { |x| x < 2 ? 1.0 : x > 2 ? -1.0 : 0.0 })
p((..8.0).bsearch { |x| x < 1 ? 1 : x > 3 ? -1 : 0 })
p((..inf).bsearch { |x| x == inf ? 0 : 1 })
p((...inf).bsearch { |x| x == inf ? 0 : 1 })
p((1.5..).bsearch { |x| x >= 100.0 })
p((1.5..).bsearch { |x| x > 3 ? -1 : x < 3 ? 1 : 0 })
p((0.0..).bsearch { |x| Math.log(x) >= 0 })

# step
t("endless") { x = []; (1.5..).step(0.5) { |v| x << v; break if x.size > 3 }; x }
t("endless int step") { x = []; (-5.0..).step(2) { |v| break if v > 3.5; x << v }; x }
t("endless excl") { x = []; (-5.0...).step(2) { |v| break if v > 3.5; x << v }; x }
t("inf end") { x = []; (1.0..Float::INFINITY).step(2) { |v| x << v; break if x.size > 2 }; x }
t("bounded") { x = []; (1.5..3.0).step(0.5) { |v| x << v }; x }
t("bounded excl") { x = []; (1.0...2.0).step(0.25) { |v| x << v }; x }
t("tenth") { x = []; (1.0..2.0).step(0.1) { |v| x << v }; x }
t("zero") { (1.5..).step(0) { |v| }; nil }
t("beginless") { (..2.5).step(0.5) { |v| }; nil }
t("break value") { (1.5..).step(0.5) { |v| break v if v > 2 } }
