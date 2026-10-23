# The two String representations refused this program; with one it answers as CRuby.
# The method reads $~ after the raise, which a watched loop leaves at the last match taken before the first turn.
def e1(t, acc)
  t.scan(/(.)(.)/) { |x, y| x << "!"; acc << x; t << "z" if acc.size == 2 }
  acc
rescue RuntimeError => e
  [e.message, acc, $~ && $~[0], $1, $2]
end
p e1(+"abcdef", [])
