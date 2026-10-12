# `freeze` changes the receiver in place. Over a shared handle it freezes the
# handle's own String and answers it, so nothing is reported.
s = +"a"
t = s
t << "b"
u = s.freeze
p u.equal?(t), t.frozen?
