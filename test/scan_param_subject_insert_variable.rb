# The two String representations refused this program; with one it answers as CRuby.
# Inserting a String that may be empty can leave the subject's length as it was, which CRuby still checks for a long subject.
def f(t, x, acc)
  t.scan(/./) { |m| m << "!"; acc << m; t.insert(0, x) }
  acc
end
p f(+"abc", "", [])
