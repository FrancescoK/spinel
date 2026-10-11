# \K keeps what was matched before it out of the match: $& and group 0
# begin where it stood and the pre-match holds the rest, while `=~` still
# answers where the matching attempt began, as in CRuby.

# the two RDoc patterns: the last name of a constant path, and issue links
p "Foo::Bar"[/::\K[^:]+\z/]
p "fix #12 and (#34)".gsub(/\b(?:(?i:fix(?:e[sd])?) +)\K\#(\d+\b)|\(\K\#(\d+)(?=\))/) { "[#{$&}](#{$1 || $2})" }

p "abc" =~ /b\Kc/
p $~.pre_match, $~.begin(0), $~[0], $~.post_match
p "abc" =~ /(?<x>b)\Kc/
m = /(?<x>a)\Kb/.match("zab")
p m[0], m[:x], m.offset(0), m.pre_match
p "abc".match(/b\K/).to_a
p "xabc".match(/a\Kb/, 1).begin(0)
p "abc".match?(/b\Kc/)
p "xay" !~ /a\K/
r = Regexp.new("b\\Kc")
p "abc"[r], "abc" =~ r

# substitution replaces only what follows the \K
p "abc".sub(/a\Kb/, "X")
p "hello world".sub(/o\K w/, "_")
p "a1 b2".gsub(/\w\K\d/) { $& * 2 }
p "abab".gsub(/a\Kb|b/, "x")
p "a-b-c".gsub(/-\K/, "+")
p "aab".sub(/a+\K/) { |s| "<#{s}>" }
s = +"xyz"
s.gsub!(/y\K/) { "+" }
p s
s = +"abc"
s[/a\Kb/] = "XY"
p s

# a match that is empty after the \K steps on as an empty match does
p "aaa".gsub(/a\K/, "-")
p "ab".gsub(/\K/, ".")
p "aaa".scan(/a\K/)
p "abcabc".scan(/b\Kc/)
p "abc".scan(/(a)\K(b)/)
p "ab\ncd".scan(/^\w\K\w/)
p "a,b".split(/,\K/)
p "aXbX".split(/X\K/)

# a backtrack past the \K takes its position back
p "abc"[/(?:a|ab)\Kc/]
p "aXbXc"[/(?:\w\K)+/]
p "ab".gsub(/(?:a\K)?b/, "*")
p "aaa".sub(/(a)\1?\K/, "!")
p "café au lait"[/é\K au/]
p "abc".slice(/a\K(b)/, 1)

# index answers group 0's start; a search tied to a position ties the
# attempt, as start_with? and the reverse searches do
p "abc".index(/b\Kc/)
p "abc".byteindex(/a\Kb/)
p "abc".start_with?(/a\Kb/)
p "abcb".rindex(/b\K/)
p "abab".rindex(/a\Kb/)
p "abab".rindex(/a\Kb/, 2)
p "abab".rindex(/a\Kb/, 1)
p "abcabc".rindex(/a\Kb/, 3)
p "abc".byterindex(/a\Kb/)
p "abc".byterindex(/a\Kb/, 0)
p "abc".partition(/b\Kc/)
p "abcbc".rpartition(/b\Kc/)
