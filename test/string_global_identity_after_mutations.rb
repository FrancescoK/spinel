# The global holds a copy of s's String. No change follows the write, but
# `equal?` still tells the copy from the String CRuby hands over (true
# there), so the write stays refused, as do `object_id` and `frozen?`.
s = +"a"
s << "b"
$g = (t = s)
p $g.equal?(s)
