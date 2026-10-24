# A String call on a String subclass instance reads the instance's String.
# Under one String representation that read is the payload itself, which a
# String slot takes back to the instance, so `m.to_s` answered m where
# CRuby answers a new String.
class MyS < String; end
m = MyS.new(+"m")
s = m.to_s
s << "!"
p m, s, s.class
t = m.to_str
t << "?"
p m, t.class
p m.itself.equal?(m), m.itself.class
u = m.upcase
p u, u.class
p m.length, (m + "z")
m << "k"
p m
