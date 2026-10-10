# String#clamp with a String Range held in a variable (or returned by a call)
# clamps to its endpoints, as a literal Range does: it raised NoMethodError.
# An exclusive Range raises only when it has an end; an endless one clamps
# from below.
r = "a".."c"
p "m".clamp(r)
p "b".clamp(r)
x = ("c"..)
p "a".clamp(x)
e = "b"..."d"
begin
  p "z".clamp(e)
rescue ArgumentError => ex
  p ex.message
end
i = 1..3
p 5.clamp(i)
f = 1.0..2.0
p 5.5.clamp(f)
p "z".clamp("a"...)
xe = ("a"...)
p "z".clamp(xe), "0".clamp(xe)
b = (.."c")
p "z".clamp(b), "a".clamp(b)
def mk(s) = s.."y"
p "z".clamp(mk("b")), "a".clamp(mk("b"))
