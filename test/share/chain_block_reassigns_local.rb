# Under --share-strings (#6765): A tap block that assigns the local the chain is over: the chain and its box stay
# on the String the chain started from, as a boxed || operand and as an arm.
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
