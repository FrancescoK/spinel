# The value of an attribute assignment kept as a String while the slot is
# mutated through another name: the kept value would be a copy. Refused.
S = Struct.new(:a, :b)
s = S.new(+"x", 1)
y = +"y"
r = (s.a = y)
t = s.a
t << "!"
p s.a, y, r
