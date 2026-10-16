# Under --share-strings (#6765): A tap block that assigns the global through a method it calls, then a bang: the
# chain runs over the handle held before the block, whatever the block assigns.
# minimal: a tap block that reassigns the global through a method, then a bang
def reset = ($g = +"zz")
def m(v) = $g.tap { reset }.upcase! || v
b = $g = +"abc"
x = m(1)
p [x, b, $g]
