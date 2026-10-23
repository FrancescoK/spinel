# The two String representations refused this program; with one it answers as CRuby.
# Appending a String that may be empty leaves the length as it was, which CRuby still checks for a long subject.
def f(t, x, acc)
  t.scan(/./) { |m| m << "!"; acc << m; t << x }
  acc
end
p f(+"abc", "", [])
