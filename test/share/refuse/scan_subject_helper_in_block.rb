# A helper the block calls changes the subject through its argument, so the refusal stays.
def helper(x) = x << "z"
s = +"ab"
acc = []
begin
  s.scan(/./) { |m| acc << m; m << "*"; helper(s) if acc.size == 1 }
rescue RuntimeError => e
  p e.message
end
p acc, s
