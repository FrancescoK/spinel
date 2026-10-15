# spinel: share
# spinel: gc-minor
# An Array of shared Strings a global, a constant or a class variable holds
# is held as their handles, and every method that reaches it sees one Array.
$g = [+"a"]
t = +"t"
$g << t
def addg(s) = $g << s
def bangg = $g.each { |x| x << "g" }
addg(+"u")
bangg
$g[0] << "!"
p $g, t

TBL = [+"k"]
TBL << t
def bangt = TBL.each { |x| x << "." }
bangt
TBL[1] << "?"
p TBL, t

class K
  @@c = [+"c"]
  def self.add(s) = @@c << s
  def self.bang
    @@c.each { |x| x << "c" }
    @@c[0] << "C"
  end
  def self.dump = p(@@c)
end
K.add(t)
K.bang
K.dump
p t
class KSub < K
  def self.more(s) = @@c << s
end
KSub.more(t)
K.bang
K.dump

$g = [+"n", t]
bangg
p $g, t
