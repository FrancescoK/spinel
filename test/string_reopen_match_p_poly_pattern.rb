# A reopening of String that defines match? answers a String receiver's
# match?, also with a boxed pattern (a Regexp or a String decided at run
# time); the builtin arm for such a pattern stands down for it (#8633).
class String
  def match?(pattern)
    "reopened #{pattern}"
  end
end
s = "abc"
pat = [/b/, "b"][ARGV.size]
p s.match?(pat)
p "x".match?(/x/)
