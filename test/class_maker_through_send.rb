# A Struct or Data class made through a literal-name send was never
# registered: the constant it was assigned to raised NameError at its first
# use.
S = Struct.send(:new, :a, :b)
p S.new(1, 2)
P = Data.send(:define, :x, :y)
p P.new(1, 2).with(y: 5)
Q = Data.public_send(:define, :x) do
  def dbl = x * 2
end
p Q.new(x: 4).dbl
T = Struct.__send__(:new, :n, keyword_init: true)
p T.new(n: 3).n
class R < Struct.send(:new, :v)
  def twice = v * 2
end
p R.new(21).twice
