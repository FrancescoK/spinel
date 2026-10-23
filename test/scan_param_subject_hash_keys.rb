# The two String representations refused this program; with one it answers as CRuby.
# A Hash literal with an object key calls the key's hash, which can change the subject in any way.
class K
  def hash = ($s.upcase!; 1)
end
def f(t, acc)
  k = K.new
  t.scan(/./) { |m| m << "!"; acc << m; h = { k => 1 } if acc.size == 1 }
  acc
end
$s = +"abc"
p f($s, [])
