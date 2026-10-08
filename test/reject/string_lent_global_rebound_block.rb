# A global handed to a yielding method's parameter that the block appends
# to, where the block assigns the global first: the spliced parameter
# aliases the global's slot, so the append would reach the new String,
# where CRuby appends to the one passed ($z ends "other"). Refused at
# compile time (#6179).
# spinel: reject-share
# spinel: reject-lent-rebound
def yl(v) = yield(v)
$z = +"z"
yl($z) { |q| $z = +"other"; q << "!" }
p $z
