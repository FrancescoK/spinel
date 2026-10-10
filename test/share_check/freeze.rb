# `freeze` changes the receiver in place, and the bytes read of it carry no
# frozen mark back to the handle: a copy no write-back covers.
s = +"a"
t = s
t << "b"
u = s.freeze
p u.equal?(t), t.frozen?
