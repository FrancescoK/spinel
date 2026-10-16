# Flag-only: under --share-strings, a ternary with a bang on an element of a
# container a builtin made on an arm answers a new String the container
# never sees: refused.
c = true
r = "ab cd ef gh".split.each_slice(2).to_a
w = c ? r[0][0].upcase! : +"q"
w << "#" if w.is_a?(String)
p r, w
