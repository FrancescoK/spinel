# A name bound to the scan's subject before the scan changes it under the block, so the refusal stays.
s = +"ab"
t = s
acc = []
begin
  s.scan(/./) { |m| acc << m; m << "*"; t << "z" if acc.size == 1 }
rescue RuntimeError => e
  p e.message
end
p acc, s
