# The two String representations refused this program; with one it answers as CRuby.
# A block that grows another name of the parameter's String (a global set by the caller), whose copy the check would not see.
$g = nil
def f(t, acc)
  t.scan(/./) { |m| m << "!"; acc << m; $g << "z" if acc.size == 1 }
  acc
rescue RuntimeError => e
  [e.message, acc]
end
a = +"abc"
$g = a
p f(a, []), a
