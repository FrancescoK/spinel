# `+=` onto a String ivar or constant whose rhs has no type (a call no
# class defines) or is poly compiles, and raises at run time

class Holder
  def initialize; @s = "a"; end
  def missing; @s += Missing.text; end
  def poly(v); @s += v[0]; @s; end
end

h = Holder.new
begin
  h.missing
rescue NameError => e
  puts e.class
end
p h.poly([1, "b"].reverse)

S = "c"
begin
  S += Object.new.no_such_method
rescue NoMethodError => e
  puts e.class
end
p S

# the slot is read before the rhs runs, even when the rhs reassigns it
class Rebinder
  def initialize; @s = "a"; end
  def rebind; @s = "q"; "c"; end
  def go; @s += rebind; @s; end
end
p Rebinder.new.go

T = "a"
T += (T = "z"; "c")
p T
