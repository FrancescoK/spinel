# `x.match(/re/)` on a value that is a String or an instance of a program
# class with its own match: the String matches, the class's match runs.
# The call compiled to the String matcher alone, whose MatchData went
# unboxed into the boxed result (a local, an `||`) and did not compile.

class Mapper
  def match(path) = [:mapped, path.source]
end

def first(t)
  if (m = t.match(/\A(\d+)/))
    m
  else
    :miss
  end
end

def either(t)
  t.nil? || t.match(/b/)
end

p first("12ab")
p first("ab")
p first(Mapper.new)
p either("abc")
p either(nil)
p either(Mapper.new)
