# The two String representations refused this program; with one it answers as CRuby.
# `itself` answers `t`, which the block changes: CRuby raises "string modified".
t = +"abc"
s = t.itself
acc = []
begin
  s.scan(/./) { |m| m << "!"; acc << m; t << "z" if acc.size == 1 }
rescue RuntimeError => e
  p e.message
end
p acc, t
