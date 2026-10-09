module M; def plus = @x; end
class N; include M; def initialize(x) = @x = x; end
src = "s".dup
v = [N.new(src).plus]
v[0] << "!"
p v, src
