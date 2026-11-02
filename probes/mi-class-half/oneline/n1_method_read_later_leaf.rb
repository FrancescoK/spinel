class Leaf; def w = :top; end; module M; def self.early = Leaf.new.w; X = early; class Leaf; def w = :m; end; end; p M::X, M.early
