# gsub! / sub! answer nil when NO SUBSTITUTION was made -- not when the text
# is unchanged: a rule that matches and writes the same bytes
# (`"cats".sub!(/s$/, "s")`) answers the string, so a rule table walked with
# `break if result.sub!(rule, replacement)` stops there instead of applying
# the next rule too (that walk is in test/sub_poly_pattern_rules.rb). Regex, string and block patterns, and the other bangs'
# unchanged-text contract stays.
s = +"cats"
p s.sub!(/s$/, "s"), s.sub!(/z/, "q"), s.gsub!("t", "t"), s.gsub!("q", "r"), s
p s.gsub!(/a/) { |m| m }, s.sub!(/x/) { "y" }, s
re = /t/
p s.sub!(re, "t"), s
b = +"abc"
p b.upcase!, b.upcase!, b.strip!, b
