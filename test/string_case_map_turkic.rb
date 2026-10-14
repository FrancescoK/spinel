words = ["iI", "İı", "Iİ", "IIi", "istanbul", "İSTANBUL", "dİyarbakır", "ÉCOLE i", "aIb"]
p "ß i".upcase(:turkic)
words.each do |w|
  p [w.upcase(:turkic), w.downcase(:turkic), w.capitalize(:turkic), w.swapcase(:turkic)]
  p [w.upcase(:turkic, :lithuanian), w.downcase(:lithuanian, :turkic)]
end
s = +"Iiİı"
s.upcase!(:turkic)
p s
s.downcase!(:turkic, :lithuanian)
p s
s.swapcase!(:turkic)
p s
s.capitalize!(:turkic)
p s
b = String.new("dİ")
b << "yar"
b.capitalize!(:turkic)
p b
p :iIı.upcase(:turkic), :İI.downcase(:turkic), :ii.capitalize(:turkic), :Iı.swapcase(:turkic)
p :éa.upcase(:ascii), :ÉA.downcase(:ascii)
box = ["Iİ", :ii, 1][0]
p box.downcase(:turkic), box.swapcase(:lithuanian, :turkic)
sym = ["x", :iI][1]
p sym.upcase(:turkic)
p "iI".b.upcase(:turkic), "iI".b.downcase(:turkic)
p "i".upcase(:lithuanian), "I".downcase(:lithuanian)
def show
  yield
rescue => e
  p [e.class, e.message]
end
show { "iI".upcase(:turkic, :turkic) }
show { "iI".upcase(:turkic, :ascii) }
show { "iI".upcase(:ascii, :turkic) }
show { "iI".upcase(:turkic, :fold) }
show { "iI".downcase(:fold, :turkic) }
show { "iI".frozen? ; "iI".freeze.upcase!(:turkic) }
p "iI".freeze.upcase(:turkic)
