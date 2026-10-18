# The backtracking engine recursed at every fork, so the C stack was the
# backtracking stack and a recursion ceiling was what kept a long subject from
# overflowing it. A greedy repetition forks once per iteration whatever its
# body holds, so that ceiling was reached by the LENGTH OF THE RUN and not by
# the nesting of the pattern: `\A(a+)b\1\z/` answered nil on a subject that is
# nothing out of the ordinary, once it passed the ceiling.
#
# The state is on the heap now, as choice points and an undo log. The ceiling
# that remains counts entries of that stack rather than C frames, so what it
# bounds is the memory one search asks for.
# (ported from mruby-regexp 7c6059908 and 3af63799f)

# Well past the 10000 C frames the old engine stopped at.
[100, 5000, 9500, 10000, 12000, 20000].each do |n|
  s = "a" * n + "b" + "a" * n
  p [n, !!(s =~ /\A(a+)b\1\z/)]
end

# A repetition whose body can match empty has to stop once an iteration ends
# where it began. The recursion ceiling was doing that by accident; the
# iteration records do it on purpose, and keep what that last iteration
# captured, as Onigmo's null check does.
p(/(a*)*\1/.match("aa").to_a)
p(/(a*)+\1/.match("aa").to_a)
p(/(a*)*\1/.match("").to_a)
p(/((a)*)\2/.match("aa").to_a)
p(/(?:(a)|(b))+\1/.match("ab").to_a)

# The same stop, reached through constructs epsilon_path() could not judge
# before: an atomic group, a lookaround and a backreference are all zero-width
# or empty-matchable, so a repetition of one is empty-matchable too.
p(/(?>a?)*/.match("b").to_a)
p(/(?>a*)*/.match("aab").to_a)
p(/(?:(?!a))*b?/.match("b").to_a)
p(/a(?:(?<=a))*b?/.match("ab").to_a)
p(/(a?)\1*/.match("").to_a)

# A lookaround and an atomic group still take a C frame each, but one is
# entered and left per construct rather than held across the text after it, so
# a REPETITION of one spends a frame at a time whatever the run, and only
# nesting in the pattern goes deep.
[200, 1000, 5000].each do |n|
  p [n, !!(("a" * n) =~ /\A(?>a)*\z/), !!(("a" * n) =~ /\A(?:(?=a)a)*\z/)]
end
[1, 50, 300].each do |d|
  p [d, !!("a" =~ Regexp.new("(?>" * d + "a" + ")" * d)),
        !!("a" =~ Regexp.new("(?=" * d + "a" + ")" * d + "a"))]
end

# The catastrophic shapes give up at a limit rather than run forever: a
# search stopped at the limit has not shown there is no match, so it raises
# RegexpError where it cannot answer instead of reading as a miss. The second
# needs a `b` the subject does not hold, which answers no match before any
# search is made, as CRuby answers it.
[/(a+)+$/, /(a*)*b\1/].each do |re|
  begin
    p(!!(("a" * 40 + "!") =~ re))
  rescue RegexpError => e
    p e.class
  end
end

# and the ordinary ones are what they were
p(/(a)\1/.match("aa").to_a)
p(/(?>ab|a)*c/.match("abac").to_a)
p(/(a)(?=\1)/.match("aa").to_a)
p(/(a)(?!\1)/.match("ab").to_a)
p("aaa".scan(/(?>a)?/).size)
