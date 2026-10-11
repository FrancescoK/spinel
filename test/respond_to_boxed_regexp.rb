# A Regexp or MatchData held in a boxed slot answers respond_to? for its own
# methods. minitest's assert_match asks `matcher.respond_to?(:=~)` of a
# matcher that may be a Regexp or a String.
def matcher_ok?(m) = m.respond_to?(:=~)
p matcher_ok?(/a/)
p matcher_ok?("a")

re = ARGV.empty? ? /(?<x>a)b/i : "ab"
p re.respond_to?(:=~)
p re.respond_to?(:match?)
p re.respond_to?(:source)
p re.respond_to?(:options)
p re.respond_to?(:names)
p re.respond_to?(:upcase)

md = ARGV.empty? ? re.match("xAB") : nil
p md.respond_to?(:[])
p md.respond_to?(:captures)
p md.respond_to?(:pre_match)
p md.respond_to?(:named_captures)
p md.respond_to?(:source)
