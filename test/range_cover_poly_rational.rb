# A boxed Rational against an Integer-range `when` compares exactly with each
# bound: 5.5 is not in 1..5, 5 is not in 1...5, and a big Rational is a number.
vals = [3, 2.5, 3r, 7r, Rational(1, 2), Rational(11, 2), 5r, -3r, Rational(2**70, 3), Rational(-(2**70), 3), "3"]
p vals.map { |v| case v when 1..5 then :in when 1.. then :up when ..5 then :down else :out end }
p vals.map { |v| case v when 1...5 then :in when 1... then :up when ...5 then :down else :out end }
