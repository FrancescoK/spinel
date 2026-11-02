class Leaf; def w = :top; end; module M; X = Leaf.new.w; class Leaf; def w = :m; end; Y = Leaf.new.w; end; p M::X, M::Y
