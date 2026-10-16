# `Object.const_get` with a literal name the program defines is that
# constant: a `new` on it builds that class alone, and the members of the
# program's other Structs keep their types (#9093), as does a local that
# holds a class read through a path (`k = R::Cam`)
module R
  Cam = Struct.new(:t, :z)
end
B = Struct.new(:b)
p B.new("s")
k = Object.const_get("R::Cam")
p k.new(1.5)
p Object.const_get(:B).new("q"), Object.const_get("::R::Cam").new(2.5, 3)
j = R::Cam
p j.new(4.5).t + 1
