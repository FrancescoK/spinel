# User methods cannot collide with the hidden prepend copies.
module L
  def m = "L " + super
end
class K
  def m = "k"
  def __prep_0_m = "user"
  def __prep_1_m = "user1"
end
k = K.new
def go(k) = [k.m, k.__prep_0_m, k.__prep_1_m]
p go(k)
class K; prepend L; end
p go(k)
