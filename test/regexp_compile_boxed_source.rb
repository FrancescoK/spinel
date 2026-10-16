# Regexp.compile is Regexp.new: a String source held in a boxed value (a
# case over several kinds) compiles to its pattern, and a Regexp given
# is copied. The compile arm read the boxed value as a C string and did
# not compile.

def normalize(formatted)
  case formatted
  when true then /.+/
  when Regexp then formatted
  when String then Regexp.compile(formatted)
  else nil
  end
end

p normalize("a.c")
p normalize("a.c").match?("abc")
p normalize(/x/)
p normalize(true)
p normalize(1)
p Regexp.compile("b+", Regexp::IGNORECASE).match?("BB")
re = Regexp.compile(/q/i)
p re
p re.match?("Q")
