# spinel: gc-stress
# An attribute assignment on a receiver of several classes, where one class's
# writer does more than store, or a Struct member was set to an Integer and
# now takes a String: each class's writer stores the value (the attr writers'
# classes raised NoMethodError).
class K; attr_accessor :a; end
class W; attr_reader :a; def a=(v); @a = v; v << "w"; end; end
objs = [K.new, W.new]
objs[1].a = +"s"
p objs[1].a
w = W.new
w.a = +"t"
p w.a
class P; attr_accessor :a; end
class Q; attr_reader :a; def a=(v); @a = v + "q"; end; end
po = [P.new, Q.new]
po.each { |o| x = (o.a = "lit"); p [x, x.frozen?, o.a, o.a.frozen?] }
S = Struct.new(:a, :b)
class K2; attr_accessor :a, :b; end
o2 = [S.new(1, 2), K2.new]
o2.each { |o| o.b = "lit" }
p o2.map(&:b)
s2 = S.new("q", 3)
p s2.a, s2.b
# a new String each class's writer takes, one of them into a member that
# was a handle: the String stays alive while the member wraps it
S3 = Struct.new(:c)
class K3; attr_accessor :c; end
o3 = [S3.new(+""), K3.new]
o3[1].c = +""
300.times { |i| o3.each { |o| o.c = o.c + i.to_s[-1]; o.c << "" } }
p o3.map { |o| o.c.size }, o3.map { |o| o.c[0, 10] }
p o3.map { |o| o.c = "#{o.c.size}-#{"q" * 3}" }
