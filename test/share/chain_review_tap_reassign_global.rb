# Under --share-strings (#6765), a chain of calls answering their receiver that
# a boxed || or && takes (chain_review: b12_tap_reassign_global) answers what CRuby 4.0 does.
# A nil a bang answered stays nil through tap and itself, and a to_s makes
# "" of it; a block that assigns the variable the chain is over leaves the
# chain on the String it started from.
# a tap block reassigning a global the chain is over
$g = +"abc"
def m(v) = $g.tap { $g = +"zz" }.upcase! || v
p m(1), $g
