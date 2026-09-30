# Range#=== / cover? / include? and `when` compare a Float against an Integer range's bounds as a Float, and a Float-bounded range that only matches keeps its bound.
p (..2) === 2.5, (...2) === 1.5, (...2) === 2.0, (..2) === 2, (..2).cover?(2.5), (..2).include?(2.0001)
p (1..) === 0.5, (1..) === 1.5, (1..).cover?(0.5), (1..2) === 2.5, (1..2).include?(1.5), (1...2).member?(1.99), (1...2) === 2.0
p (..2.5) === 2.5, (..2.5) === 2.7, (...2.5) === 2.2, (1.5..) === 1, (1.5..) === 2
p (1..3.5) === 3.2, (1..3.5) === 3.7, (1...3.5) === 3.4, (1..3.5).include?(3.2), (1...3.5).include?(3)
p (1..2) === Float::NAN, (..2) === -Float::INFINITY, (1..2).cover?(Float::INFINITY), (1..2.5).cover?(1..2)
r = (1..2); f = 2.5
p r === f, r.cover?(f), r.include?(f), r.member?(1.5)
def m(r, x) = r === x
p m(1..2, 2.5), m(1..2, 1.5), m(..2, 2.5)
q = {a: 1..2, b: "x"}[:a]
p q === 2.5, q.cover?(2.5), q.include?(2.5), q.include?(1.5)
p(case 2.5 when ..2 then :a when 2..3 then :b end)
p(case 1.5 when 1...2 then :a else :b end, case 2.0 when 1...2 then :a else :b end)
x = [2.5, 1][0]
p(case x when ..2 then :a when 2..3 then :b end)
def g(v) = case v when ...1.5 then :lo when 1.5.. then :hi end
p g(1.4), g(1.5), g(1), g(2)
lim = 2.5
p [2.3, 2, 2.6, -0.5].map { |v| case v when 0..lim then :in when ..0 then :neg else :out end }
p(case "s" when ..2.5 then :a else :b end)
