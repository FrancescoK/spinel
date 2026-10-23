# The two String representations refused this program; with one it answers as CRuby.
# A constant subject changed by its own block.
S = +"ab"
acc = []
begin
  S.scan(/./) { |m| acc << m; m << "*"; S << "z" if acc.size == 1 }
rescue RuntimeError => e
  p e.message
end
p acc, S
