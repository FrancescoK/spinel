# A String pushed into a global Array is the element itself; the element
# store does not follow a global, so the append through the element would
# not reach s: refused.
# spinel: reject-share
s = +"a"
$a = []
$a << s
$a[0] << "!"
p s
