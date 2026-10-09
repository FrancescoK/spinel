# A subject read through a call, changed by its own block.
class B
  attr_reader :s
  def initialize; @s = +"ab"; end
end
b = B.new
acc = []
begin
  b.s.scan(/./) { |m| acc << m; m << "*"; b.s << "z" if acc.size == 1 }
rescue RuntimeError => e
  p e.message
end
p acc, b.s
