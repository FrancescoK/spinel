# prepend + super
module P; def get = super + "p"; end
module Q; def get = @x; end
class A; prepend P; def initialize(x) = @x = x; def get = @x; end
class C; include Q; def initialize(x) = @x = x; end
src = "s".dup
os = [A.new(src), C.new(src)]
w = [os[0].get, os[1].get]
w[0] << "?"
w[1] << "!"
p w, src
