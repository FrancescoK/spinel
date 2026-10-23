# The two String representations refused this program; with one it answers as CRuby.
# A boxed receiver's String transforms whose answers are boxed (strip,
# center), kept in an Array beside a String changed through another name and
# appended to through it: the dispatch boxes each new String as its bytes,
# whose copies stop naming one String once one is appended to, so the
# program stays refused.
$all = []
b = +"buf"; $all << b; b << "!"
s = +"  Orig-x "
x = ARGV.size > 0 ? 1 : s
r = [x.strip, x.center(14, "*"), x.b, x.swapcase, x.delete("-"), x.squeeze, x.tr_s("x", "y")]
r.each { |e| $all << e; e << "." }
p s, r, $all
