# Under --share-strings (#6765), a chain of calls answering their receiver that
# a boxed || or && takes (chain_review: h09_tap_reassign_then_freeze) answers what CRuby 4.0 does.
# A nil a bang answered stays nil through tap and itself, and a to_s makes
# "" of it; a block that assigns the variable the chain is over leaves the
# chain on the String it started from.
# a tap reassigning the local, then freeze: the original is frozen, not the new one
def m(v)
  s = +"abc"
  o = s
  x = s.tap { s = +"zz" }.freeze || v
  [x, o.frozen?, s.frozen?]
end
p m(1)
