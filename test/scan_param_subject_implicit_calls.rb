# The two String representations refused this program; with one it answers as CRuby.
# An interpolated instance variable calls its to_s, which can change the subject in any way.
class O
  def initialize(s) = @s = s
  def to_s
    @s.upcase!
    "o"
  end
end
class R
  def initialize(o) = @o = o
  def run(t)
    acc = []
    t.scan(/./) { |m| m << "!"; acc << m; x = "#@o" if acc.size == 1 }
    [acc, t]
  rescue RuntimeError => e
    [e.message, acc, t]
  end
end
s = +"abc"
p R.new(O.new(s)).run(s)
