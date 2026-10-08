# `when *arr` with a Regexp in arr sets $~ the way a plain `when /re/` does:
# the match on a hit, nil when the Regexp is tried and misses. It used to
# leave $~ as it was.

PATS = [/b+/, 1..3]
x = case "abbc" when *PATS then :hit else :miss end
p x, $~ && $~[0]
"zq" =~ /q/
y = case 2 when *PATS then :hit else :miss end
p y, $~
"zq" =~ /q/
z = case "xyz" when *PATS then :hit else :miss end
p z, $~
w = case :abb when *PATS then :hit else :miss end
p w, $~ && $~[0]

# grep keeps leaving $~ alone
"zq" =~ /q/
p %w[ab cd].grep(PATS[0]), $~[0]
