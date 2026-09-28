class M3; end
module Cmp; end
case M3
in Class then p :yes
else p :no
end
p(Class === M3)
p(Module === M3)
p(Class === Comparable)
p(Module === Comparable)
p(Class === 1)
p(Class === String)
case M3
when Class then p :wc
else p :wno
end
case M3
when Module then p :wm
else p :wmno
end
case M3
in Class => k then p k
end
case M3
in Module then p :im
end
k = M3
p k.is_a?(Class)
p k.kind_of?(Module)
arr = [M3, 1]
p arr[0].is_a?(Class)
p arr[1].is_a?(Class)
h = {a: M3}
p h[:a].kind_of?(Class)
p h[:a].is_a?(Module)
p Cmp.is_a?(Class)
p Cmp.is_a?(Module)
case 5
in Class then p :bad
else p :ok
end
p String.is_a?(Class)
p String.instance_of?(Class)
p Comparable.is_a?(Class)
p Cmp.instance_of?(Module)
k = String
p k.is_a?(Class)
case Cmp
when Class then p :c
when Module then p :m
end
case String
when Object then p :o
end
def chk(v)
  [Class === v, Module === v, v.is_a?(Class), v.kind_of?(Module)]
end
p chk(M3)
p chk(Cmp)
p chk(1)
p chk(String)
p chk(Comparable)
p [M3, 1, Cmp, String, Kernel].grep(Class)
p [M3, 1, Cmp, String, Kernel].grep(Module)
p [M3, 1, Cmp].select { |v| Class === v }
@iv = Cmp
p(Class === @iv, Module === @iv)
$gv = M3
p(Class === $gv, Module === $gv)
case Cmp
in Class => k then p [:c, k]
in Module => k then p [:m, k]
end
case Kernel
when Class then p :c
when Module then p :m
end
p Cmp.instance_of?(Module), Cmp.instance_of?(Class), M3.instance_of?(Class), M3.instance_of?(Module)
p(Module === 1, Class === nil, Class === "s")
h = {a: Cmp, b: M3}
h.each { |k, v| p [k, Class === v, v.is_a?(Class), v.is_a?(Module)] }
p(Class === Class, Module === Class, Class === Module)
p(Object === M3, BasicObject === Cmp)
