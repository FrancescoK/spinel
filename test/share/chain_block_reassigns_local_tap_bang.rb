# Under --share-strings (#6765): A tap block that assigns the local the chain is over, then a bang, as a boxed ||
# operand: the bang changes the String the chain started from.
# minimal: a tap block reassigning the local the chain is over
def m(v)
  s = +"abc"
  x = s.tap { s = +"zz" }.upcase! || v
  [x, s]
end
p m(1)
