module N; end
module M
  N::X = 1
end
class C; X = 3; def x = X; end
X = 2
p N::X, X, C::X, C.new.x
