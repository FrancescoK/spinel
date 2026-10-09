module M; def plus = @x; end
class N; include M; def initialize(x) = @x = x; end
src = "s".dup
w = N.new(src).plus
w << "!"
p w, src
