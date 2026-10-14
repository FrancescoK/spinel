# spinel: share
# spinel: gc-minor
# join, include?, ==, inspect, puts and interpolation read the Strings.
s = +"s"
a = [s, +"t", +"u"]
s << "!"
p a.join, a.join("|"), a.join(", ")
p a.include?("s!"), a.include?("zz")
b = [s, +"t", +"u"]
c = [s]
d = []
p a == b, a == c, a == d, c == c, d == b
d << s
p d == c
puts a.inspect
puts a.to_s
puts a
puts "#{a} #{a.size}"
p a.to_a.size
p a
e = [+"é", +"日本"]
p e.join("-"), e.size, e.inspect
f = [+"x"]
p f.join(+"é")
