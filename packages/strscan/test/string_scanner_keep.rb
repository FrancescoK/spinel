require "strscan"

# A \K in a scanner's pattern: scan and skip still step from the pointer to
# the match's end, while matched, pre_match and post_match read the match,
# which begins at the \K.
s = StringScanner.new("abcabc")
p s.scan(/a\Kb/), s.pos, s.matched, s.pre_match, s.post_match
p s.check(/c\Ka/), s.pos, s.matched
p s.match?(/ca\Kb/), s.matched, s.pre_match
p s.skip(/c\Ka/), s.pos, s.matched
p s.scan(/x\K/), s.matched?
p s.scan_until(/b\Kc/), s.pos, s.matched, s.pre_match

s = StringScanner.new("key: value")
p s.scan(/\w+:\s*\K/), s.matched, s.pos, s.rest
p s.scan(/\w+/)

# the pattern must still match at the pointer: a \K is no search ahead
s = StringScanner.new("xab")
p s.scan(/a\Kb/), s.pos
