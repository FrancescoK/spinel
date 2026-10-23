# The two String representations refused this program; with one it answers as CRuby.
# A subject a conditional's arm hands `t`, which the block changes: CRuby raises "string modified".
t = +"abc"
s = ARGV.size > 5 ? 1 : t
acc = []
begin
  s.scan(/./) { |m| m << "!"; acc << m; t << "z" if acc.size == 1 }
rescue RuntimeError => e
  p e.message
end
p acc, t
