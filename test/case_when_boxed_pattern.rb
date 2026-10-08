# A `when` value read out of an Array matches by ===, as CRuby's does: a
# Regexp matches a String, a Range covers, a Class is is_a?. It compared
# with == and every one of them missed.

class Pt
  attr_reader :x
  def initialize(x) = @x = x
  def ==(o) = o.is_a?(Pt) && o.x == x
end
PATS = [/b+/, 1..3, Integer, "lit", 2.0, Pt.new(1), :sym, nil]
def which(v)
  PATS.each_with_index do |pat, i|
    case v
    when pat then return i
    end
  end
  -1
end
p which("abbc"), which("xyz"), which(2), which(7), which("lit")
p which(Pt.new(1)), which(:sym), which(nil), which(2.0)

# a shared String subject matches the Regexp too
s = +"cbb"
pr = proc { |t| t << "!" }
pr.call(s)
p which(s)
x = case "abbc" when PATS[0] then :hit else :miss end
p x, $~ && $~[0]
y = case :abbc when PATS[0] then :hit else :miss end
p y

