class N; def initialize(x) = @x = x; def get = @x; alias plus get; end
src = "s".dup
v = [N.new(src).plus]
v[0] << "!"
p v, src
