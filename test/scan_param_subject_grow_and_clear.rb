# The two String representations refused this program; with one it answers as CRuby.
# A block that both grows and clears the subject could leave its length as it was with other bytes.
def f(t, acc)
  t.scan(/./) { |m| m << "!"; acc << m; t << "q"; t.clear }
  acc
end
p f(+"abc", [])
