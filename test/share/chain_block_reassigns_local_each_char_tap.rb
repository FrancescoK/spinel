# Under --share-strings (#6765): An each_char block that assigns the local, then a bang and an empty tap.
# minimal: each_char reassigning the local, a bang, an empty tap
def m(v)
  s = +"aBc"
  x = s.each_char { s = +"q" }.swapcase!.tap { } || v
  [x, s]
end
p m(1)
