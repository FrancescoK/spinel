# A Method bound to one of a String's in-place mutators: the Method holds
# the String's value, not the String, so a call could not change the
# String it came from (it crashed). `.method` is refused, naming the line.
# spinel: reject-string-method
s = +"abc"
t = s
s.method(:<<).call("!")
s.method(:upcase!).to_proc.call
p t
