# An index write through a getter shared by many classes, on a receiver
# that may be any of them, widens every class's ivar.

class KA
  def initialize = @c = {0 => 0}
  def cache = @c
end
class KASub < KA; end
class KB
  def initialize = @c = {1 => 1}
  def cache = @c
end
class KBSub < KB; end
class KC
  def initialize = @c = {2 => 2}
  def cache = @c
end
class KCSub < KC; end
class KD
  def initialize = @c = {3 => 3}
  def cache = @c
end
class KDSub < KD; end
class KE
  def initialize = @c = {4 => 4}
  def cache = @c
end
class KESub < KE; end
class KF
  def initialize = @c = {5 => 5}
  def cache = @c
end
class KFSub < KF; end
class KG
  def initialize = @c = {6 => 6}
  def cache = @c
end
class KGSub < KG; end
class KH
  def initialize = @c = {7 => 7}
  def cache = @c
end
class KHSub < KH; end
class KI
  def initialize = @c = {8 => 8}
  def cache = @c
end
class KISub < KI; end
class KJ
  def initialize = @c = {9 => 9}
  def cache = @c
end
class KJSub < KJ; end
class KK
  def initialize = @c = {10 => 10}
  def cache = @c
end
class KKSub < KK; end
class KL
  def initialize = @c = {11 => 11}
  def cache = @c
end
class KLSub < KL; end
class KM
  def initialize = @c = {12 => 12}
  def cache = @c
end
class KMSub < KM; end
class KN
  def initialize = @c = {13 => 13}
  def cache = @c
end
class KNSub < KN; end
class KO
  def initialize = @c = {14 => 14}
  def cache = @c
end
class KOSub < KO; end
class KP
  def initialize = @c = {15 => 15}
  def cache = @c
end
class KPSub < KP; end
class KQ
  def initialize = @c = {16 => 16}
  def cache = @c
end
class KQSub < KQ; end
class KR
  def initialize = @c = {17 => 17}
  def cache = @c
end
class KRSub < KR; end

objs = [KA.new, KASub.new, KB.new, KBSub.new, KC.new, KCSub.new, KD.new, KDSub.new, KE.new, KESub.new, KF.new, KFSub.new, KG.new, KGSub.new, KH.new, KHSub.new, KI.new, KISub.new, KJ.new, KJSub.new, KK.new, KKSub.new, KL.new, KLSub.new, KM.new, KMSub.new, KN.new, KNSub.new, KO.new, KOSub.new, KP.new, KPSub.new, KQ.new, KQSub.new, KR.new, KRSub.new]
objs.each { |o| o.cache["x"] = "y" }
objs.each { |o| p o.cache }
