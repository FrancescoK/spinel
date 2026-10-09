s = +"abc"
p0 = ->(x) { x }
p1 = ->(x) { p0.call([x])[0] }
p2 = ->(x) { p1.call([x])[0] }
p3 = ->(x) { p2.call([x])[0] }
p4 = ->(x) { p3.call([x])[0] }
p5 = ->(x) { p4.call([x])[0] }
p6 = ->(x) { p5.call([x])[0] }
p7 = ->(x) { p6.call([x])[0] }
p8 = ->(x) { p7.call([x])[0] }
p9 = ->(x) { p8.call([x])[0] }
p10 = ->(x) { p9.call([x])[0] }
p11 = ->(x) { p10.call([x])[0] }
r = p11.call(s)
r << "!"
p s
