# The two String representations refused this program; with one it answers as CRuby.
# A subject that is one of two Strings of an Array literal, the block changing one of them: CRuby raises "string modified" when it is the subject.
t = +"abc"
u = +"xy"
s = [u, t, 1][ARGV.size]
acc = []
begin
  s.scan(/./) { |m| m << "!"; acc << m; u << "z" if acc.size == 1 }
rescue RuntimeError => e
  p e.message
end
p acc, t, u
