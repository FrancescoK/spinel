# Under --share-strings (#6765), a chain of calls answering their receiver that
# a boxed || or && takes (chain_review: k01_min_tap_reassign_local) answers what CRuby 4.0 does.
# A nil a bang answered stays nil through tap and itself, and a to_s makes
# "" of it; a block that assigns the variable the chain is over leaves the
# chain on the String it started from.
# minimal: a tap block reassigning the local the chain is over
def m(v)
  s = +"abc"
  x = s.tap { s = +"zz" }.upcase! || v
  [x, s]
end
p m(1)
