# The value of an attribute assignment on a receiver whose class is known only
# at run time is the String it was handed, whatever writer each class has: an
# attr writer stores that String, an explicit writer is handed it, and a Struct
# member keeps it. Kept in a variable, an element or a method's answer, it is
# one String with the right-hand side and the field, so a change through any
# of them shows through the others.
class K
  attr_accessor :a
end
class M
  attr_reader :a
  def a=(v)
    v << "w"
    @a = v
    3
  end
end
S = Struct.new(:a)

# kept in a variable, then read and changed
s = +"s"
s << "1"
[K.new, S.new(nil)].each do |o|
  x = (o.a = s)
  p x, x.size
end
[K.new, M.new, S.new(nil)].each do |o|
  x = (o.a = s)
  x << "!"
  p x, s, o.a, x.equal?(s), o.a.equal?(s)
end

# kept in an Array
t = +"t"
r = []
[K.new, M.new].each { |o| r << (o.a = t) }
t << "?"
p r

# a method's answer
def put(o, v) = (o.a = v)
u = +"u"
[K.new, S.new(nil)].each { |o| y = put(o, u); y << "#"; p y, o.a }
p u

# a new String the writers share with the assignment's value
w = +"w"
[K.new, M.new].each { |o| z = (o.a = w.dup); z << "d"; p z, o.a, w }

# writers of both kinds in a map block: each element is the String
class K3; attr_accessor :a; end
class M3; def a=(v); @a = v; end; def a = @a; end
t3 = +"s"
a1 = [K3.new, M3.new].map { |r| r.a = t3 }
a1[0] << "!"
p a1, t3

# a method answering the assignment, as an endless def and a body's last
class K4; attr_accessor :a; end
class M4; attr_accessor :a; end
def put2(o, s) = (o.a = s)
def put3(o, s)
  o.a = s
end
t4 = +"z"
v4 = put2([K4.new, M4.new][0], t4)
v4 << "1"
w4 = put3([K4.new, M4.new][1], t4)
w4 << "2"
p t4, v4.equal?(t4), w4.equal?(t4)

# the assignment a statement of its own: the field holds the String, and a
# later change through the variable shows in it
class K5; attr_accessor :a; end
class M5; attr_accessor :a; end
t5 = +"s"
objs5 = [K5.new, M5.new]
objs5.each { |r| r.a = t5 }
t5 << "z"
p objs5.map(&:a)

# a Struct member beside a class with its own writer, as a value and as a
# statement: each stores the String itself
S6 = Struct.new(:a)
class K6; def a=(v); @a = v; end; def a = @a; end
t6 = +"t"
[S6.new(nil), K6.new].each { |o| x = (o.a = t6); p x.equal?(t6) }
o6 = [S6.new(nil), K6.new]
o6.each { |q| q.a = t6 }
t6 << "!"
p o6.map(&:a)

# a writer that changes the String it is handed: the assignment's value,
# read as a String, is that String after the change
class K7; def a=(v); v << "!"; @a = v; end; attr_reader :a; end
class M7; attr_accessor :a; end
[K7.new, M7.new].each { |o| p((o.a = +"ef").size); x = (o.a = +"cd"); p x }

# writers that do more than store, a Struct member set to Integers
# elsewhere, and a writer's value read as a String in a map block
class P10; attr_accessor :a; end
class Q10; attr_reader :a; def a=(v); v << "!"; @a = v; end; end
class R10; attr_reader :a; def a=(v); @a = v.dup; v.replace("R"); end; end
class T10; attr_reader :a; def a=(v); v.freeze; @a = v; end; end
[P10.new, Q10.new, R10.new, T10.new].each do |o|
  s = +"v"
  x = (o.a = s)
  p [x, s, o.a, x.equal?(s), x.frozen?, (o.a = +"ef").size]
end
p [P10.new, Q10.new].map { |o| (o.a = +"ef").size }
class K11; attr_accessor :a; end
class W11; attr_reader :a; def a=(v); @a = v; v << "w"; end; end
o11 = [K11.new, W11.new]
o11.each { |o| o.a = +"s" }
p o11.map(&:a)
S12 = Struct.new(:a, :b)
class K12; attr_accessor :a, :b; end
t12 = +"x"
o12 = [S12.new(1, 2), K12.new]
o12.each { |o| o.a = t12; o.b = "lit" }
t12 << "y"
p o12.map(&:a), o12.map(&:b)
