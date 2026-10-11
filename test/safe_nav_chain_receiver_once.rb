# A chain of safe navigations run as a statement evaluates its receiver once:
# the receiver of each `&.` link is the value of the link before it, not a
# second run of the chain (a counting method, a bang that answers nil when
# run again, a writer that counts its calls, an Array).
$n = 0
def f = ($n += 1; +"x")
f&.<<("a")&.<<("b")
p $n
f&.upcase&.downcase
p $n
u = +"u"
u.sub!("u", "y")&.<<("1")&.<<("2")
p u
class W
  attr_reader :n
  def initialize = (@n = 0)
  def c=(v)
    @n += 1
  end
end
w = W.new
s = +"s"
(w.c = s)&.<<("?")&.<<("?")
p w.n
a = [1, 2]
a.push(3)&.push(4)&.push(5)
p a
