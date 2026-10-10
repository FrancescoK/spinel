# An in-place change that reads the handle's bytes and writes the answer
# back into the handle (`sp_String_set_bin(h, f(bytes of h))`): the read
# declares itself, and the check reports nothing here.
s = +"abc"
t = s
s.succ!
p s
p t
