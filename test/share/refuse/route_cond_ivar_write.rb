# Flag-only: under --share-strings, an ivar's write takes a conditional's
# value whole, a copy of the arm that ran, so @t would not be s: refused.
$cnd = true
s = +"abc"
@t = ($cnd ? s : +"x")
@t << "!"
p s
