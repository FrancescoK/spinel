# A lambda the block calls changes the subject, so the refusal stays.
s = +"ab"
bump = -> { s << "z" }
acc = []
begin
  s.scan(/./) { |m| acc << m; m << "*"; bump.call if acc.size == 1 }
rescue RuntimeError => e
  p e.message
end
p acc, s
