# An operator assignment to an attribute on a receiver whose class is known
# only at run time (`r.a += "x"`) gives the field a new String, and the
# assignment's value is that String: kept in a variable and changed in place,
# the change shows in the field.
class K; attr_accessor :a; end
class M; attr_accessor :a; end
t = +"s"
objs = [K.new, M.new]
objs.each { |r| r.a = t }
objs.each { |r| x = (r.a += "x"); x << "?"; p [x, r.a, t] }
r2 = []
objs.each { |r| r2 << (r.a += "y") }
r2[0] << "!"
p objs[0].a, objs[1].a

# three classes, one of them with its own writer, and the values kept by a
# map block: one String each, changed in place through the field or the value
class P3; attr_accessor :a; end
class Q3; attr_accessor :a; end
class R3; attr_reader :a; def a=(v); @a = v; end; end
objs3 = [P3.new, Q3.new, R3.new]
objs3.each { |r| r.a = +"s" }
objs3.each { |r| r.a += "x" }
objs3.each { |r| r.a << "?" }
p objs3.map(&:a)
objs3.each { |r| x = (r.a += "y"); x << "!"; p [x, r.a] }
objs3.each { |r| r.a ||= +"no"; r.a << "#" }
p objs3.map(&:a)
y3 = objs3.map { |q| q.a += "m" }
y3.each { |v| v << "%" }
p y3, objs3.map(&:a)

# a Struct member, an attr writer and a writer that changes its argument
S13 = Struct.new(:a)
class K13; attr_accessor :a; end
class W13; attr_reader :a; def a=(v); @a = v; v << "w"; end; end
o13 = [S13.new(+"s"), K13.new, W13.new]
o13[1].a = +"k"; o13[2].a = +"w"
r13 = o13.map { |o| x = (o.a += "+"); x << "?"; x }
p r13, o13.map(&:a)
