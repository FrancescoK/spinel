# A constant subject changed by its own block.
S = +"ab"
acc = []
begin
  S.scan(/./) { |m| acc << m; m << "*"; S << "z" if acc.size == 1 }
rescue RuntimeError => e
  p e.message
end
p acc, S
