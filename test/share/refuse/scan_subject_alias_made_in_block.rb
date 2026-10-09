# An alias made inside the block changes the subject, so the refusal stays.
s = +"ab"
acc = []
begin
  s.scan(/./) { |m| acc << m; m << "*"; u = s; u << "z" if acc.size == 1 }
rescue RuntimeError => e
  p e.message
end
p acc, s
