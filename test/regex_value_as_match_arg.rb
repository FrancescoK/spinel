# A regex in argument position may be any expression, not just a local or a
# constant read. An inline `Regexp.new(s)` / `Regexp.union(..)` / a method
# returning a regex is the same pattern value, and String#match / #match? /
# #=~ / #!~ / #scan must take it the way #sub / #gsub / #split already do.
# spinel: gc-minor
def re
  /\d/
end

# --- inline call in argument position
p "1d".match(Regexp.new("\\d"))
p "1d".match?(Regexp.new("\\d"))
p("1d" =~ Regexp.new("\\d"))
p("1d" !~ Regexp.new("\\d"))
p "1d".scan(Regexp.new("\\d"))
p "a1b2".match(Regexp.union("b", "1"))
p "a1b2".scan(Regexp.union("1", "2"))

# a call returning a plain literal is still a call
p "1d".match(re)
p "1d".match?(re)
p("1d" =~ re)
p "a1b2".scan(re)

# --- the same expression bound to a local keeps working
r = Regexp.new("\\d")
p "1d".match(r)
p "1d".match?(r)
p("1d" =~ r)
p("1d" !~ r)
p "a1b2".scan(r)

# --- literals and constant-bound literals stay on their own paths
LIT = /\d/
p "1d".match(/\d/)
p "1d".match?(/\d/)
p("1d" =~ /\d/)
p "a1b2".scan(/\d/)
p "a1b2".scan(/(\d)(\w)/)
p "1d".match(LIT)

# --- interpolated literal in argument position
sep = "d"
p "1d".match(/#{sep}/)
p "1d".match?(/#{sep}/)
p "a1b2d".scan(/#{sep}|\d/)
p "a1b2".scan(/(#{sep}|\d)(\w)/)

# --- a run-time pattern's capture groups are only knowable at run time:
# no groups yields whole matches, groups yield a row per match
p "a1b2".scan(Regexp.new("\\d"))
p "a1b2".scan(Regexp.new("(\\d)(\\w)"))
p "abc".scan(Regexp.new("\\d"))

# --- scan's block form returns self and yields each whole match
p("a1b2".scan(Regexp.new("\\d")) { |m| print m })

# --- the reported site: an interpolated pattern built with Regexp.new,
# consumed directly in an `if` condition
INTERVALS = { "h" => 3600, "m" => 60 }
def parse(param)
  if m = param.to_s.match(Regexp.new("\\A(\\d+)([#{INTERVALS.keys.join}])\\z"))
    m[1].to_i * INTERVALS[m[2]]
  end
end
p parse("12h")
p parse("30m")
p parse("nope")

# --- the start-position form takes a run-time pattern too
p "a1b2".match(Regexp.new("\\d"), 2)
p "a1b2".match?(Regexp.new("\\d"), 2)
p "a1b2".match(r, 2)

# --- a poly receiver (a String read out of a widened container) is coerced
# into the subject slot rather than passed through raw
mixed = ["a1b2", 7]
poly = mixed[0]
p poly.match(Regexp.new("\\d"))
p poly.match?(Regexp.new("\\d"))

# --- Regexp on the receiver side is unchanged
p Regexp.new("\\d").match("1d")
p Regexp.new("\\d").match?("1d")
