# Under --share-strings a rescue modifier whose value is a shared String
# (`r = s.upcase!.downcase! rescue nil`) hands on that String, or nil, or
# its fallback's: the variable, instance variable, global or parameter it
# goes to names the String the other names hold.
s = +"ab"
r = s.upcase!.downcase! rescue nil
p s, r, r.equal?(s)
t = +"AB"
q = t.upcase! rescue "none"
p q
q = t.downcase! rescue "none"
q << "1"
p t, q.equal?(t)
u = (raise "boom"; t) rescue t
u << "2"
p t, u.equal?(t)
v = (t.foo! rescue t.upcase!)
v << "3"
p t
def grow(b) = (b << "!"; nil)
grow((t.downcase! rescue nil))
p t
class C
  def initialize(s) = (@s = s)
  def set = (@r = (@s.upcase! rescue nil))
  attr_reader :r
end
w = +"cd"
c = C.new(w)
c.set
c.r << "4"
p w, c.r.equal?(w)
$g = (w.downcase! rescue nil)
$g << "5"
p w
