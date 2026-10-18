# spinel: not-cruby -- the escapes the engine refuses raise RegexpError, where CRuby matches them
# `\R`, `\X` and `\p{...}` each meant something here that the engine did
# not do, and as unknown escapes each was its own letter: /\R/ matched an R
# rather than a newline, and /\p{Alpha}/ answered a pattern that asked for a
# letter with the text of the request. Ported from mruby-regexp 2e7e38a80 and
# ef283321f; upstream refuses `\G` and `\g<name>` in the same commit, and both
# are carried here already, so they keep working. `\R` is carried now too
# (test/regexp_linebreak_escape.rb).
def t(label)
  r = begin
    yield.inspect
  rescue => e
    e.class.to_s
  end
  puts label + " | " + r
end

t("bs-R")      { Regexp.new("\\R") =~ "\n" }
t("bs-X")      { Regexp.new("\\X") =~ "a" }

# \G and \g<name> are carried, and keep working
t("bs-G")      { Regexp.new("\\Ga") =~ "a" }
t("bs-G-mid")  { Regexp.new("a\\Gb") =~ "ab" }
t("bs-g-name") { Regexp.new("(?<x>a|b)\\g<x>").match("ab")[0] }
t("bs-g-quote"){ Regexp.new("(?<x>a|b)\\g'x'").match("ab")[0] }

# so is \K (test/regexp_keep.rb), but inside a lookaround, where CRuby's
# reading of it is not one the engine follows, it is still refused
t("bs-K")      { Regexp.new("a\\Kb") =~ "ab" }
t("bs-K-look") { Regexp.new("(?=a\\K)") =~ "ab" }
t("prop-p")    { Regexp.new("\\p{Alpha}") =~ "a" }
t("prop-P")    { Regexp.new("\\P{Alpha}") =~ "1" }
t("prop-unknown") { Regexp.new("\\p{Hiragana}") =~ "a" }

# a bare `\g` is the letter in CRuby too, and stays one; so is a bare `\p`
# and the unbraced `\pL`
t("bare-g")    { Regexp.new("\\g").match("g")[0] }
t("bare-p")    { Regexp.new("\\p").match("p")[0] }
t("pL")        { Regexp.new("\\pL").match("pL")[0] }

# inside a character class CRuby reads \R and \K as the letter, and so does
# the class parser here
t("class-R")   { Regexp.new("[\\R]").match("R")[0] }
t("class-K")   { Regexp.new("[\\K]").match("K")[0] }

# \p/\P are carried now (#4143), inside a class as well as outside: CRuby
# reads a property escape inside a class as a property test there too, not as
# its literal letters, so these answer rather than raising. A property the
# engine does not carry still raises, naming it -- see
# test/regexp_unicode_property.rb, which covers the ones it does.
t("class-p")     { Regexp.new("[\\p{Alpha}]") =~ "a" }
t("class-P-neg") { Regexp.new("[^\\p{Word}\\- \\t]").match("a d_1") }
