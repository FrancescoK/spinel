# The two String representations refused this program; with one it answers as CRuby.
# A block that changes the parameter subject without changing its length: CRuby scans on over the changed bytes, which a length check cannot see.
def f(t, acc)
  t.scan(/./) { |m| m << "!"; acc << m; t.upcase! if acc.size == 1 }
  acc
end
p f(+"abc", [])
