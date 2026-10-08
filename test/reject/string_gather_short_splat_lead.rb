# A String written ahead of a splat, with an optional parameter before the
# rest and a required one after it: how long the splat runs decides which
# parameter takes the String (here a when e has an element, z when it is
# empty), and the one that appends would grow a copy out of the gathered
# Array. Refused rather than compiled with the append lost (#6179).
# spinel: reject-share
def g(a = nil, *r, z) = (a << "!" if a.is_a?(String); [r, z])
e = ARGV.empty? ? [] : [1]
s = +"s"
p g(s, *e)
p s
