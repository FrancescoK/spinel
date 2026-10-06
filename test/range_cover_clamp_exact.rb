# spinel: int64
# cover?, include?, === and clamp between an Integer and a Float bound
# compare exactly, as == and <=> do since #7505: an Integer past 2^53 does
# not round onto a Float bound. Typed and boxed, Integer and Float Ranges.
a = 9007199254740993      # 2**53 + 1
f = 9007199254740992.0    # 2**53
def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
# cover? / include? / === : Integer Range, Float value
t { (a..a).cover?(f) }
t { (a..a).include?(f) }
t { (a..a) === f }
t { (0..f).cover?(a) }
t { (0...a).cover?(f) }
# Float Range, Integer value
t { (0.0..f).cover?(a) }
t { (f..f).cover?(a) }
t { (f..).cover?(a) }
# cover?(range)
t { (0..f).cover?(a..a) }
t { (0.0..f).cover?(a..a) }
# boxed
t { [(a..a), 1][0].cover?(f) }
t { [(0.0..f), 1][0].cover?(a) }
t { [(0.0..f), 1][0].cover?([a, 1][0]) }
# clamp
t { a.clamp(0.0, f) }
t { a.clamp(0, f) }
t { f.clamp(a, a) }
t { a.clamp(..f) }
t { a.clamp(0.0..f) }
t { f.clamp(a..a) }
t { [a, 1][0].clamp(0.0, f) }
t { [f, 1][0].clamp(a, a) }
n = -9007199254740993     # -(2**53 + 1)
g = -9007199254740992.0
t { (n..n).cover?(g) }
t { (g..0.0).cover?(n) }
t { n.clamp(g..0.0) }
t { (0...f).cover?(a) }
t { (0.0...f).cover?(9007199254740991) }
t { (1..2.5).cover?(2) }
t { (1.5..3.0).cover?(1) }
t { (1.5..3.0).cover?(2) }
t { 3.clamp(1.5..2.5) }
t { 2.7.clamp(1..2) }
t { 0.5.clamp(1..2) }
t { (1..2.5).cover?(1..2) }
t { (1...3.0).cover?(1..2) }
