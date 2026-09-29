# An endless ("a"..) or beginless (.."m") String range is a String range with
# a nil bound, not an Integer range whose String bound raises TypeError.

p("a"..)
r = ("b"..)
b = (.."m")
p r, b, ("b"...)
puts r.to_s, b.to_s
p r.begin, r.end, b.begin, b.end
p r.cover?("a"), r.cover?("zz"), b.cover?("n"), b.cover?("c")
p r === "c", b === "z"
case "k"
when ("x"..) then p :x
when (.."m") then p :m
end
p r == ("b"..), r == ("b"...), r == ("b".."c")
p({r => 1}[("b"..)])
p r.exclude_end?, ("b"...).exclude_end?
begin
  r.to_a
rescue RangeError => e
  p e.message
end
begin
  b.to_a
rescue TypeError => e
  p e.message
end
begin
  b.include?("a")
rescue TypeError => e
  p e.message
end
p ("a".."c").include?("b"), ("a".."c").to_a
