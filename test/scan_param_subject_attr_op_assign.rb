# The two String representations refused this program; with one it answers as CRuby.
# An op-assign through a writer calls it, which can change the subject in any way.
class Box
  attr_reader :x
  def x=(v)
    $s.upcase!
    @x = v
  end
end
def f(t, acc, o)
  t.scan(/./) { |m| m << "!"; acc << m; o.x ||= 1 }
  acc
end
$s = +"abc"
p f($s, [], Box.new)
