# A valid case-mapping option other than a literal :ascii maps ASCII text as
# CRuby does: :fold, :lithuanian, and :turkic on text without i or I, and an
# option read at run time.
p "ABC".downcase(:fold), "aBc".upcase(:lithuanian), "abc".upcase(:turkic)
p "XyZ".swapcase(:turkic, :lithuanian), "hello".capitalize(:lithuanian, :turkic)
p :ABC.downcase(:fold), :abc.upcase(:turkic)
s = +"ABC"
s.downcase!(:fold)
p s
o = [:ascii, 1][ARGV.size]
p "ab".upcase(o), "AB".downcase(o), :ab.capitalize(o)
f = [:fold, 1][ARGV.size]
p "QRS".downcase(f)
