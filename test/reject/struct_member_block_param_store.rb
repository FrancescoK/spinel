# A block parameter stored into a String member that is mutated through
# another name: the parameter holds no handle to hand over, so the member
# would keep a copy the Array element never sees. Refused.
S = Struct.new(:a)
s = S.new(+"x")
[+"e"].each { |v| s.a = v }
t = s.a
t << "!"
p s.a
