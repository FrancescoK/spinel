# Under --share-strings (#6765): A tap block that assigns the global the chain is over, then a bang.
# a tap block reassigning a global the chain is over
$g = +"abc"
def m(v) = $g.tap { $g = +"zz" }.upcase! || v
p m(1), $g
