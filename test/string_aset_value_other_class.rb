# String#[]= in value position (`x = (s[i] = v)`, an argument) given a
# value of a class with no #to_str. The store raises CRuby's TypeError
# converting it, but the value form evaluated the right-hand side again as
# the call's String answer, so an Integer or a Symbol went into the String
# slot and the generated C did not build.

def t(k)
  s = +"Hello"
  r = k == 0 ? +"Hello" : nil
  y = [:s, 1][k]
  p(begin; x = (s[1] = 7); x; rescue TypeError => e; e.message; end)
  p(begin; r[1] = 7; rescue TypeError => e; e.message; end)
  p(begin; s[1, 2] = :z; rescue TypeError => e; e.message; end)
  p(begin; s[y, y] = :z; rescue TypeError => e; e.message; end)
  p(begin; s[[1.5, 1][k]] = nil; rescue TypeError => e; e.message; end)
  p(s[0] = "J")
  p s, r
end

t(ARGV.size)
