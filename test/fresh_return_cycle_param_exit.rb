# The two String representations refused this program; with one it answers as CRuby.
# A cycle of methods whose way out answers a parameter (here the String
# the caller holds) is not a cycle of new Strings, whichever of the two
# methods the program defines first (aa defined first): the walk's rounds settle on what
# each method answers, a new String or its parameter, not on whether it
# answers at all. The answer stays refused, as without the cycle rule.
$all = []
b = +"buf"; $all << b; b << "!"
def aa(x, n)
  if n > 0
    bb(x, n - 1)
  else
    x
  end
end
def bb(x, n) = aa(x, n)
s = +"held"
r = [bb(s, 3)]
r.each { |e| $all << e; e << "." }
p s, r, $all, r[0].equal?(s)
