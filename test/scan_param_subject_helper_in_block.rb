# The two String representations refused this program; with one it answers as CRuby.
# A block that calls a method of the program's, which could change the subject in any way, keeps the refusal.
def h(x) = x.upcase!
def f(t, acc)
  t.scan(/./) { |m| m << "!"; acc << m; h(t) if acc.size == 1 }
  acc
end
p f(+"abc", [])
