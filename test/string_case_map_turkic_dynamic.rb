def show
  yield
rescue => e
  p [e.class, e.message]
end
locale = :turkic
p "i".upcase(locale)
p "I".downcase(locale)
p "iI".swapcase(locale)
p "istanbul".capitalize(locale)
lith = :lithuanian
p "i".upcase(locale, lith)
p "I".downcase(lith, locale)
bad = :bogus
show { "iI".upcase(locale, bad) }
show { "iI".upcase(bad) }
v = ["x", :turkic][1]
p "i".upcase(v)
w = ["i", :i][0]
p w.upcase(locale)
