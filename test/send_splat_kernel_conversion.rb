class O
  def hi(*a) = a.size
end

def call(o, m, *args) = o.send(m, *args)
def call_blk(o, m, *args, &) = o.send(m, *args, &)

p call(O.new, :hi, 1, 2)
p call_blk(O.new, :hi, 3) { 0 }

p call(nil, :Integer, "12")
p call(nil, :Integer, "ff", 16)
p call(nil, :Hash, nil)
p call(nil, :Float, "1.5")
p call(nil, :String, 3)

begin
  call(nil, :Hash, 1, 2)
rescue ArgumentError => e
  puts e.message
end

begin
  call(nil, :Integer)
rescue ArgumentError => e
  puts e.message
end

p %i[Array Hash Integer Float String Rational Complex].size
