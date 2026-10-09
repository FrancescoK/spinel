module M; def self.keep(v) = (@a = v); def self.a = @a; end
s = +"abc"
M.keep(s)
(M.a) << "?"
p s
p(M.a)
