# A global handed to a parameter the method appends to is lent its C slot,
# and the method assigns the global before it appends: through the slot the
# append would reach the new String, where CRuby appends to the one passed
# (it prints "new"). A global is not yet shared by reference, so this is
# refused at compile time (#6179).
# spinel: reject-share
# spinel: reject-lent-rebound
def gr2(v) = ($g = +"new"; v << "x")
$g = +"g"
gr2($g)
p $g
