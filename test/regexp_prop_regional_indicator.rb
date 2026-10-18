# \p{RI}, Regional_Indicator: the 26 letters U+1F1E6..U+1F1FF two of which
# make a flag; \P{RI} is the rest, and the long name and its spellings
# read the same.
s = "flags \u{1F1EF}\u{1F1F5} and \u{1F1FA}\u{1F1F8}! a"
p s.scan(/\p{RI}/).size
p s.scan(/\p{RI}{2}/)
p s =~ /\P{RI}/
p s.scan(/[\p{RI}a]/).size
p "x" =~ /\p{Regional_Indicator}/
p "\u{1F1E6}" =~ /\p{regional-indicator}/
