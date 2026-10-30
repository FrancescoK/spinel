# A String subclass whose #to_s answers self (Active Support's SafeBuffer)
# is a String wherever a String is read: interpolating it, or its #to_s
# call, takes its bytes -- CRuby's rb_obj_as_string takes any T_STRING as it
# is, so the subclass's own #to_s does not run in an interpolation, while an
# explicit call does -- and a poly #to_s dispatch over it answers them in the
# String slot. The instance's struct pointer landed in a const char * and the
# C did not build.
class SafeBuffer < String
  def to_s
    self
  end
end
class Plain < String
end
class Loud < String
  def to_s
    "LOUD"
  end
end
class Pt
  def initialize(x); @x = x; end
  def to_s; "pt#{@x}"; end
end
sb = SafeBuffer.new("hi")
pl = Plain.new("yo")
ld = Loud.new("quiet")
puts "a #{sb}"
puts "b #{pl}"
puts "c #{sb.to_s}"
puts "d #{pl.to_s}"
puts "e #{ld}"
puts "f #{ld.to_s}"
puts "g #{SafeBuffer.new("fresh")}"
puts sb
puts sb.to_s
puts pl.to_s
puts "h " + sb.to_s
puts "i " + pl.to_s
puts sb.to_s.equal?(sb)
def given(key, *extras)
  n = extras.length + 1
  s = n.to_s
  puts "given " + s
end
given(1)
given(1, 2)
x = [Pt.new(1), 3, sb, pl, ld]
x.each { |e| puts "j #{e}"; s = e.to_s; puts "k " + s }
x.each { |e| puts "l #{e.to_s}" }
