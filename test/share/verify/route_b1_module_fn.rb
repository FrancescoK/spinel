module M; def self.keep(v) = (@a = v); def self.a = @a; end
s = +"abc"
M.keep(s)
s << "!"
p(M.a)
p s
