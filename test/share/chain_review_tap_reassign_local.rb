# Under --share-strings (#6765), a chain of calls answering their receiver that
# a boxed || or && takes answers what CRuby 4.0 does; a block that assigns
# the variable the chain is over leaves the chain on the String it started from.
# a tap block that reassigns the local the chain is over
def m(v)
  s = +"abc"
  x = s.tap { s = +"zz" }.itself || v
  [x, s]
end
p m(1)
def n(v)
  s = +"abc"
  x = v ? s.tap { s = +"yy" }.upcase! : 1
  [x, s]
end
p n(true)
