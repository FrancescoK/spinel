# The String surface on a boxed receiver beyond the zero-argument arms: a
# case mapping given options (checked as the typed call checks them, a
# Symbol mapped too), dump, undump and grapheme_clusters. A non-String
# receiver answers NoMethodError naming its own class.
def t(&b) = (b.call rescue "#{$!.class}: #{$!.message}")
i = 0
x = [+"ab", 1][i]
y = [:Sy, 1][i]
n = [1, "s"][i]
u = [+"é", 1][i]
p x.upcase(:ascii), x.downcase(:fold), x.capitalize(:ascii), x.swapcase(:ascii)
p y.upcase(:ascii), y.swapcase(:turkic)
p t { x.upcase(:bogus) }
p t { x.upcase(:ascii, :turkic) }
puts u.upcase(:ascii)
p x.dump, [+"hé", 1][i].dump
p x.dump.undump
p((x.undump rescue $!.class))
p x.grapheme_clusters
p t { n.upcase(:ascii) }
p t { n.dump }
p t { n.grapheme_clusters }
z = x.upcase(:ascii)
p z + "!"
