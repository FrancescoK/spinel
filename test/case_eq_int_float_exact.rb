# spinel: int64
# === and the case/when and case/in matching built on it compare an Integer
# with a Float exactly, as == does since #7505: an Integer past 2^53 is not
# rounded onto the Float. Small values and literals match as before.
a = 9007199254740993
f = 9007199254740992.0
p(case a; when f then :eq; else :ne; end)
p(case f; when a then :eq; else :ne; end)
p(case [a, 1][0]; when f then :eq; else :ne; end)
p(case a; when 9007199254740992.0 then :eq; else :ne; end)
p(case a; when 9007199254740993.0 then :eq; else :ne; end)
p f === a, a === f, a === 9007199254740992.0
n = -9007199254740993
p(case n; when -9007199254740992.0 then :eq; else :ne; end)
p(case 3; when 3.0 then :eq; else :ne; end)
x = 3
y = 3.0
p(case x; when y then :eq; else :ne; end)
p(case y; when x then :eq; else :ne; end)
p(case x; when 2.5, 3.0 then :eq; else :ne; end)
p(case x; when Float::NAN then :eq; else :ne; end)
p 3 === 3.0, 3.0 === 3, x === y, y === x
p(case 9007199254740992; when f then :eq; else :ne; end)
a = 9007199254740993
f = 9007199254740992.0
p(case a; in ^f then :eq; else :ne; end)
p(case f; in ^a then :eq; else :ne; end)
p(case a; in 9007199254740992.0 then :eq; else :ne; end)
p(case 3; in 3.0 then :eq; else :ne; end)
x = 3
y = 3.0
p(case x; in ^y then :eq; else :ne; end)
p(case y; in ^x then :eq; else :ne; end)
p(case a; in [1, 2] then :a; in ^f then :f; else :ne; end)
