# The two String representations refused this program; with one it answers as CRuby.
# A boxed subject read off an Array literal holding `t`, which the block changes: CRuby raises "string modified".
t = +"abc"
s = [t, 1].first
acc = []
begin
  s.scan(/./) { |m| m << "!"; acc << m; t << "z" if acc.size == 1 }
rescue RuntimeError => e
  p e.message
end
p acc, s, t
