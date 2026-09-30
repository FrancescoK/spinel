# String#[Range] / #slice(Range) with a start before -length is nil like
# CRuby, through the literal, Range-value, poly and Symbol arms.
s = "abc"
p s[-4..], s[-4...], s[-4..-1], s[-5..2], s.slice(-4..)
p s[-3..], s[3..], s[4..], s[-4, 2], s[0..-5], s[..-5]
r = (-4..)
p s[r], s.slice(-4...2), "ab#{s.size}"[-4..]
i = -4
p s[i..], s[i..i + 5]
p "añb"[-4..], "añb"[-3..], "abc".b[-4..]
p ""[-1..], ""[0..]
p s[-4..] || "fallback"
x = [s, 1][0]
p x[-4..], x[r]
p :abc[-4..], :abc[r]
t = s.dup
p t.slice!(-4..), t
