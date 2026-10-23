# The two String representations refused this program; with one it answers as CRuby.
# A cycle of locals over the subject's String, the block changing one of them: CRuby raises "string modified".
t = +"abc"
s = [t, 1].first
t = s if ARGV.size > 2
acc = []
begin
  s.scan(/./) { |m| m << "!"; acc << m; t << "z" if acc.size == 1 }
rescue RuntimeError => e
  p e.message
end
p acc, t
