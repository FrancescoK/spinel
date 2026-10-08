# A String gathered into a rest that the method yields with a splat to a
# block that appends to it: the element is a copy, as for any splat into a
# yield. Refused rather than compiled with the append lost (#6179).
# spinel: reject-share
def y(*r) = yield(*r)
s = +"s"
y(1, s) { |a, b| b << "!" }
p s
