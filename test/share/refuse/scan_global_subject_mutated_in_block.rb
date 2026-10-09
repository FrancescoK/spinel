# A global subject changed by its own block.
$s = +"ab"
acc = []
begin
  $s.scan(/./) { |m| acc << m; m << "*"; $s << "z" if acc.size == 1 }
rescue RuntimeError => e
  p e.message
end
p acc, $s
