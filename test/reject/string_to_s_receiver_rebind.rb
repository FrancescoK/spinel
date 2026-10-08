# `e.to_s` is e's own String, which `<<` appends to before the argument
# rebinds e; q names the same String. The `to_s` read is a copy today, so q
# would miss the append and r would be the new String: refused.
# spinel: reject-share
e = +"a"
q = e
q << "!"
r = e.to_s << (e = +"b")
p r, q
