# A top-level ivar handed to a parameter the method appends to is lent its
# C slot (civ_Toplevel_x), and the method assigns the ivar before it
# appends: through the slot the append would reach the new String, where
# CRuby appends to the one passed (it prints "new"). Refused at compile
# time until such an ivar is shared by reference (#6179).
# spinel: reject-share
# spinel: reject-lent-rebound
def gri(v) = (@x = +"new"; v << "x")
@x = +"k"
gri(@x)
p @x
