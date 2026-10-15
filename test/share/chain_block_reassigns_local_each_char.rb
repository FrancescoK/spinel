# Under --share-strings (#6765): An each_char block that assigns the local the chain is over, then a bang, as a
# boxed || operand: the bang runs on the String the chain started from.
# minimal: each_char whose block reassigns the local, then a bang, as an || operand
def m(v)
  s = +"abc"
  x = s.each_char { s = +"q" }.upcase! || v
  [x, s]
end
p m(1)
