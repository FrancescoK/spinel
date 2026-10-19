# A pattern's search state is taken by its first search, not when it is
# compiled: a pattern searched only after others were, one searched
# again inside its own gsub block, and a long alternation built at run
# time all answer as CRuby's do.
WORD = /(\w+)-(\d+)/
LATER = /b+c/
p "aa-1 bb-22".scan(WORD)
r = "aa-1 bb-22 cc-333".gsub(WORD) do
  inner = $~[0] =~ WORD ? [$1, $2] : nil
  "#{inner.inspect}"
end
p r
words = (1..300).map { |i| "w#{i}x" }
long = Regexp.new("\\A(?:" + words.join("|") + ")\\z")
p long.match?("w1x"), long.match?("w300x"), long.match?("w301x")
p "w150x" =~ long, $~[0]
p "xxabbbcd"[LATER], LATER.match("abc").pre_match
p "aXbXc".split(/X/), "a1b22c".gsub(/\d+/) { |d| d.size.to_s }
